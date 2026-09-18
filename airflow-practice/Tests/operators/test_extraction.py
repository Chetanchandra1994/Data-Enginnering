import pytest
from unittest.mock import MagicMock
from plugins.operators.extraction import ExtractionOperator

class TestExtractionOperatorPrefix:
    
    @pytest.fixture
    def operator(self):
        """Fixture to initialize the operator with mocked connectors."""
        mock_source = MagicMock()
        mock_targets = [MagicMock(),MagicMock()]
        return ExtractionOperator(
            task_id='test_task',
            source=mock_source,
            targets=mock_targets
        )

    def test_prefix_returns_stream_if_xcom_exists(self, operator):
        # 1. Setup: Source has a key, and XCom returns a value
        operator.source.xcom_key = 'last_record_ts'
        operator.source.file_prefix = None
        ti = MagicMock()
        ti.xcom_pull.return_value = '2026-05-14 10:00:00'

        # 2. Act
        determined = operator._determine_prefix(ti)
        for t in operator.targets:
            t.file_prefix = determined

        # 3. Assert
        for t in operator.targets:
            assert t.file_prefix == 'stream'
        ti.xcom_pull.assert_called_with(key='last_record_ts', include_prior_dates=True)

    def test_prefix_returns_fullload_on_first_run(self, operator):
        # 1. Setup: Source has a key, but XCom is empty (first run)
        operator.source.xcom_key = 'last_record_ts'
        operator.source.file_prefix = None
        ti = MagicMock()
        ti.xcom_pull.return_value = None

        # 2. Act
        determined = operator._determine_prefix(ti)
        for t in operator.targets:
            t.file_prefix = determined

        # 3. Assert
        for t in operator.targets:
            assert t.file_prefix == 'fullload'
        ti.xcom_pull.assert_called_with(key='last_record_ts', include_prior_dates=True)

    def test_prefix_uses_source_override(self, operator):
        # 1. Setup: No XCom key, but source connector has a hardcoded prefix
        operator.source.xcom_key = None
        operator.source.file_prefix = 'stream'
        for t in operator.targets:
            t.file_prefix = None
        ti = MagicMock()

        # 2. Act
        determined = operator._determine_prefix(ti)
        for t in operator.targets:
            t.file_prefix = determined

        # 3. Assert
        for t in operator.targets:
            assert t.file_prefix == 'stream'
        ti.xcom_pull.assert_not_called()
    
    def test_target_connector_cannot_override_prefix_on_initial_run(self, operator):
        # 1. Setup: Target has an initial "wrong" prefix
        operator.source.xcom_key = None
        operator.source.file_prefix = None
        for t in operator.targets:
            t.file_prefix = 'initial_value'
        ti = MagicMock()

        # 2. Act
        determined = operator._determine_prefix(ti)
        for t in operator.targets:
            t.file_prefix = determined

        # 3. Assert
        for t in operator.targets:
            assert t.file_prefix == 'fullload'
        ti.xcom_pull.assert_not_called()

    def test_target_connector_cannot_override_prefix_on_stream(self, operator):
        # 1. Setup: Target has an initial "wrong" prefix
        operator.source.xcom_key = 'last_record_ts'
        operator.source.file_prefix = None
        for t in operator.targets:
            t.file_prefix = 'initial_value'
        ti = MagicMock()
        ti.xcom_pull.return_value = '2026-05-14 10:00:00'

        # 2. Act
        determined = operator._determine_prefix(ti)
        for t in operator.targets:
            t.file_prefix = determined

        # 3. Assert
        for t in operator.targets:
            assert t.file_prefix == 'stream'
        ti.xcom_pull.assert_called_with(key='last_record_ts', include_prior_dates=True)
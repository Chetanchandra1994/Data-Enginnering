SELECT CURRENT_ORGANIZATION_NAME(), CURRENT_ACCOUNT_NAME(), current_user();

-- CURRENT_ORGANIZATION_NAME()	CURRENT_ACCOUNT_NAME()
-- QNFANFA	                        QI17075


ALTER USER CHETANCHANDRA81 SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtRLW+QTGmZsiOySXVstT8sexVfFPt884VJki731fnH9fGm/rcB6/aUMwujDiWxxFp7iU/munKAr/oFdAgk4yB27svUZxm1gN16H7WhLkBZbMNr5ZEoK8g4u9YkoYdkqL2OLExCp+saHxFj3t8CjjfcxhTYguZEPVAd80TYfMtl1Lomm/MLv7o/Qk4NyPZTuySZShVwd2Oh7jqpTYycBKu1UW1wxhTxr5JoyC++IXmqMgVKHutkX3NgjsDvlG7u5sYgLxgBIcns1JypD2r8tgwNJ5jkHEt22Zvn6p9PqyX1+AkqdTwduaJhdjF4dmZ42qbLLdNK9ttzbfJrmmA0VqfwIDAQAB';

DESC USER CHETANCHANDRA81;

SHOW DATABASES LIKE 'ADVWORKS_PREPROD';
/*
created_on	name	is_default	is_current	origin	owner	comment	options	retention_time	kind	owner_role_type	object_visibility	data_quality_monitoring_settings	resharing_settings
2026-09-06 05:28:58.085 -0700	ADVWORKS_PREPROD	N	N		ACCOUNTADMIN			1	STANDARD	ROLE			
*/

SHOW SCHEMAS IN DATABASE ADVWORKS_PREPROD;
/*
created_on	name	is_default	is_current	database_name	owner	comment	options	retention_time	owner_role_type	classification_profile_database	classification_profile_schema	classification_profile	object_visibility	is_nested
2026-09-06 05:29:41.844 -0700	INFORMATION_SCHEMA	N	N	ADVWORKS_PREPROD		Views describing the contents of schemas in this database		1						false
2026-09-06 05:29:00.310 -0700	LANDING	N	N	ADVWORKS_PREPROD	ACCOUNTADMIN			1	ROLE					false
2026-09-06 05:28:59.405 -0700	MARKETPLACE	N	N	ADVWORKS_PREPROD	ACCOUNTADMIN			1	ROLE					false
2026-09-06 05:29:00.468 -0700	NORMALIZE	N	N	ADVWORKS_PREPROD	ACCOUNTADMIN			1	ROLE					false
2026-09-06 05:29:00.425 -0700	PREPARE	N	N	ADVWORKS_PREPROD	ACCOUNTADMIN			1	ROLE					false
2026-09-06 05:28:58.111 -0700	PUBLIC	N	N	ADVWORKS_PREPROD	ACCOUNTADMIN			1	ROLE					false
2026-09-06 05:29:00.322 -0700	SCHEMATIZE	N	N	ADVWORKS_PREPROD	ACCOUNTADMIN			1	ROLE					false
*/

SHOW WAREHOUSES LIKE 'ETL_WH_PREPROD';
/*
name	state	type	size	min_cluster_count	max_cluster_count	started_clusters	running	queued	is_default	is_current	auto_suspend	auto_resume	available	provisioning	quiescing	other	created_on	resumed_on	updated_on	owner	comment	enable_query_acceleration	query_acceleration_max_scale_factor	resource_monitor	actives	pendings	failed	suspended	uuid	scaling_policy	owner_role_type	resource_constraint	generation	query_throughput_multiplier	max_query_performance_level	disabled_reasons	tables
ETL_WH_PREPROD	SUSPENDED	STANDARD	X-Small	1	1	0	0	0	N	N	60	true					2026-09-06 05:28:59.059 -0700	2026-09-06 05:28:59.140 -0700	2026-09-06 05:28:59.140 -0700	ACCOUNTADMIN		false	8	null	0	0	0	1	8468431173	STANDARD	ROLE						
*/
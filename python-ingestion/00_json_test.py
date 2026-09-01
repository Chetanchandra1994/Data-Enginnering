import json
from datetime import date
from decimal import Decimal

record = {
    "CustomerKey": 11000,
    "FirstName": "Jon",
    "BirthDate": date(1971, 10, 6),
    "YearlyIncome": Decimal("90000.0000")
}

# print(record)

json_data = json.dumps(record, default = str)

print(json_data)
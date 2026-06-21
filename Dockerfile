FROM python:3.12.0-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY spiris/ /app/spiris/
COPY scripts/ /app/scripts/

WORKDIR /app/spiris

CMD ["sh", "-c", "dbt run --profiles-dir . && dbt test --profiles-dir . --select marts && python ../scripts/export.py"]
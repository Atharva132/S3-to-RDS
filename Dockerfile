FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install --no-cache-dir -r requirements.txt

COPY  s3_to_rds.py ${LAMBDA_TASK_ROOT}

CMD [ "s3_to_rds.lambda_handler" ]
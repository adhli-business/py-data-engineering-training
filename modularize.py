# %%
import glob
import os
import json
import re
import pandas as pd

# %%
def get_column_names(schemas, table):
    return [col['column_name'] for col in sorted(schemas[table], key=lambda col: int(col["column_position"]))]

# %%
def read_csv(file, schemas):
    ds_names = re.split('[/\\\\]', file)[-2]
    column_names = get_column_names(schemas,  ds_names)
    return pd.read_csv(file, header=None, names=column_names)

# %%
def to_json(df, target_base_dir, ds_name, file_name):
    json_file_path = f'{target_base_dir}/{ds_name}/{file_name}'
    os.makedirs(f'{target_base_dir}/{ds_name}', exist_ok=True)
    df.to_json(json_file_path, orient='records', lines=True)

# %%
def file_converter(src_base_dir, target_base_dir, ds_name):
    schemas = json.load(open(f'{src_base_dir}/schemas.json'))
    files = glob.glob(f'{src_base_dir}/{ds_name}/part-*')
    for file in files:
        df = read_csv(file, schemas)
        file_name = re.split('[/\\\\]', file)[-1]
        to_json(df, target_base_dir, ds_name, file_name)

# %%
def process_files():
    src_base_dir = 'data/retail_db'
    target_base_dir = 'data/retail_db_json'
    schemas = json.load(open(f'{src_base_dir}/schemas.json'))
    ds_names = schemas.keys()
    for ds_name in ds_names:
        print(f'Processing {ds_name}')
        file_converter(src_base_dir, target_base_dir, ds_name)


# %%
process_files()



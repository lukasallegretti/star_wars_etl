""" Receive Star Wars API route """
from flask import Flask, request
from flask_restx import Resource, Namespace, Api

from dao.load_data import load_data, upload_s3_file


VALIDATE_TABLES = [
    'vehicles',
    'people',
    'species',
    'starships',
    'planets',
    'films'
]

app = Flask(__name__)
api = Api(
    app,
    version=1.0,
    title='Star Wars Challenger',
    description='API regarding the Blu challenge'
)

api = api.namespace(
    'star-wars',
    description='Send Star Ward data'
)

@api.route('/<string:table>')
class ReceiveGenericData(Resource):
    """
    Defines HTTP methods for the 'star_wars_api' namespace
    """
    def post(self, table: str):
        """ Load data on database and s3 """
        
        if table in VALIDATE_TABLES:
            data = request.json
            results = data['results']
            for result in results:
                load_data(result, table)
                upload_s3_file(table)
            
        else:
            return api.abort(
                404,
                'Not found, the table inserted was not found'
            )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
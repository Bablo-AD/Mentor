from flask import Flask,request
from flask_restful import Resource, Api
import recommendation_system

app = Flask(__name__)
api = Api(app)
youtube = recommendation_system.youtube_recommender()
class youtube_handler(Resource):
    def put(self):
        aspiration = request.form['interest']
        print(aspiration)
        try:
            short_journal = request.form['short_journal']
        except KeyError:
            short_journal = None
        try:
            journal = request.form['journal']
        except KeyError:
            journal = None
        
        if short_journal is not None:
            print(short_journal)
            return youtube.execute(aspiration,short_journal=short_journal)
        elif journal is not None:
            print(journal)
            return youtube.execute(aspiration,journal=journal)

class journal2short_journal(Resource):
    def put(self):
        journal = request.form['journal']
        return {"short_journal":recommendation_system.Tools.journal2short_journal(journal)}

api.add_resource(youtube_handler, '/recommendation_system/youtube_recommend')
api.add_resource(journal2short_journal, '/recommendation_system/tools/journal2short_journal')
if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
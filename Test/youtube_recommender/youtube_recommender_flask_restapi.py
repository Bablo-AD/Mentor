from flask import Flask,request
from flask_restful import Resource, Api
from youtube_recommend import youtube_recommender

app = Flask(__name__)
api = Api(app)
youtube = youtube_recommender()
class youtube_handler(Resource):
    def put(self):
        aspiration = request.form['interest']
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

api.add_resource(youtube_handler, '/youtube_recommend')

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')
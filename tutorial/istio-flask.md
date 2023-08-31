
### 1. flask 설치 ###
```
pip install flask
pip install flask-migrate
```

### 2. 서비스 개발 ###
[app.py]
```
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/prod/<int:prod>', methods=['GET'])
def index(prod):
    return jsonify({ prod: 'ok' })

if __name__ == "__main__":
    app.run(host="localhost", port=3001, debug=False)
```

```
python app.py
```

## 레퍼런스 ##

* https://doitgrow.com/37#google_vignette

* [점프 투 플라스크](https://wikidocs.net/book/4542)

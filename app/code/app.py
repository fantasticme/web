from flask import Flask,render_template,request
from multiprocessing import Process
from collections import defaultdict

app = Flask(__name__)
visitors = defaultdict(int)

@app.route("/")
def index():
    visitors[request.remote_addr] += 1
    return render_template('index.html')


@app.route("/home")
def home():
    visitors[request.remote_addr] += 1
    return render_template('app/home.html')

@app.route("/music")
def music():
    visitors[request.remote_addr] += 1
    return render_template('app/music.html')

@app.route("/video")
def video():
    visitors[request.remote_addr] += 1
    return render_template('app/video.html')

@app.route("/weather")
def weather():
    visitors[request.remote_addr] += 1
    return render_template('app/weather.html')

@app.route("/calendar")
def calendar():
    visitors[request.remote_addr] += 1
    return render_template('app/calendar.html')

@app.route("/about")
def about():
    visitors[request.remote_addr] += 1
    return render_template('app/about.html')

@app.route('/visitors')
def get_visitor_counts():
    return f'独立访客数量：{len(visitors)}'


if __name__ == "__main__":
    processes = []
    for i in range(4):  # 使用4个进程来处理连接请求
        p = Process(target=app.run, kwargs={"debug": True, "use_reloader": False, "port": 5000+i})
        p.daemon = True
        processes.append(p)
        p.start()
    for p in processes:
        p.join()


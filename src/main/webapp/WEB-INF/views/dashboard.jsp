<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>


<title>SeeSeeCallCall Dashboard</title>

<script src="<c:url value="/resources/js/Chart.js/Chart.min.js"/>"></script>
<script src="<c:url value="/resources/js/Chart.js/samples/utils.js"/>"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.16.0/moment-with-locales.min.js"></script>
	

<style>
canvas {
	-moz-user-select: none;
	-webkit-user-select: none;
	-ms-user-select: none;
}

/* 테이블 표시 영역 (최대 3개의 행 표시) */
#table-wrapper {
	overflow-y: auto;
	height: 250px;
}

#table-wrapper thead th {
	position: sticky;
	top: 0;
	background: white;
}

/* Just common table stuff. Really. */
table {
	/* border-collapse: collapse;
	width: 100%; */
}

th, td {
	padding: 8px 16px;
}

.rounded-background {
	background: white;
	border-radius: 5px;
}

.topic-msg-size-wrapper {
	margin-top: -60px; /* -80px */
}

.client-msg-wrapper {
	margin-top: 5px;
}

.platform-content {
	padding-top: 50px;
	padding-bottom: 50px; /* 80px; */
}

.platform-label {
	margin-right: 10px;
	margin-left: 5px;
	font-size: 25px;
	font-weight: bold;
	display: inline-block;
	width: 30px;
	text-align: center;
}

.platform-figures-name {
	margin-right: 10px;
	font-size: 15px;
	font-weight: bold;
}

.partition {
	margin-top: -20px;
}

</style>
<div class="partition">
<!--  <div class="partition-title"> Total amount of topic figures </div> -->
<div class="container-wrapper">
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-3">
				<div class="col-md-12 rounded-background">
					<p class="chart-title">Message Size</p>
					<canvas id="msgSizeChart"></canvas>
				</div>
			</div>
			<div class="col-md-3">
				<div class="col-md-12 rounded-background">
					<p class="chart-title">Connections & Senders</p>
					<canvas id="connectionAndSenderChart"></canvas>
				</div>
			</div>
			<div class="col-md-3">
				<div class="col-md-12 rounded-background">
					<p class="chart-title">Message Publish Count</p>
					<canvas id="msgPublishCountChart"></canvas>
				</div>
			</div>
			<div class="col-md-3">
				<div class="col-md-12 rounded-background">
					<p class="chart-title">Platform</p>
					<p class="platform-content">
						<img src="<c:url value="/resources/images/android-logo.png"/>"
							width="80" height="80"> <span class="platform-label"
							id="androidLabel">00</span><span class="platform-figures-name">users</span>
						<img src="<c:url value="/resources/images/ios-logo.png"/>"
							width="80" height="80"> <span class="platform-label"
							id="iOSLabel">00</span><span class="platform-figures-name">users</span>
					</p>
				</div>
			</div>
		</div>
	</div>
</div>
<!-- </div> -->


	<!--  <div class="partition-title"> Each amount of topic figures </div> -->
	<div class="container-wrapper">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-6">
					<div class="col-md-12 rounded-background" id="table-wrapper">
						<p class="chart-title">Topics in use</p>
						<table id="topicTable" class="table table-hover w-auto">
							<thead>
								<tr>
									<th scope="col" style="width: 10%">#</th>
									<th scope="col" style="width: 20%">Topic</th>
									<th scope="col" style="width: 40%">Start Date</th>
									<th scope="col" style="width: 10%">Participants</th>
									<th scope="col" style="width: 20%">Duration</th>
								</tr>
							</thead>
							<tbody id="topicTableBody">
								<tr></tr>
								<tr></tr>
								<tr></tr>
								<tr></tr>
								<tr></tr>
							</tbody>
						</table>
					</div>
				</div>
				<div class="col-md-6">
					<div class="col-md-12 rounded-background">
						<p class="chart-title">Components</p>
						<canvas id="componentChart" height="110"></canvas>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="container-wrapper">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-6">
					<div
						class="col-md-12 rounded-background topic-msg-size-wrapper">
						<p class="chart-title">Topic Message Size</p>
						<canvas id="topicMsgSizeChart" height="120"></canvas>
					</div>
				</div>
				<div class="col-md-3">
					<div
						class="col-md-12 rounded-background client-msg-wrapper">
						<p class="chart-title">Client Message Size</p>
						<canvas id="clientMsgSizeChart" height="205"></canvas>
					</div>
				</div>
				<div class="col-md-3">
					<div
						class="col-md-12 rounded-background client-msg-wrapper">
						<p class="chart-title">Client Publish Count</p>
						<canvas id="clientMsgPublishCountChart" height="205"></canvas>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>


<div></div>

<script>
	var labels = ['30', '27', '24', '21', '18', '15', '12', '9', '6', '3', '0'];
	var data = [];
	var connectionData = [];
	var messageData = [];
	var charts = [];
	var speed = 250;

	var msgSize = [];
	var connections = [];
	var msgPublishCount = [];
	var senders = [];

	var topics = [];
	var durations = [];

	var components = [];
	var stroke;
	var rect;
	var oval;
	var text;
	var image;

	var curTopic;
	var curComponent;

	var curClients = [];
	var curClientsName = [];
	var curClientsMsgSize = [];
	var curClientsMsgPublishCount = [];

	var topicMsgSize = [];

	var Android; // number of
	var iOS;

	/* 차트 */
	var msgSizeChart;
	var connectionAndSenderChart;
	var msgPublishCountChart;
	var platformRatioChart;

	var componentChart;
	var topicMsgSizeChart;
	var clientMsgSizeChart;
	var clientMsgPublishCountChart;


	window.onload = function() {
		console.log("window.onload");
		
		initializeData();
		initializeChart();

		getData();
		
		startTimer();
		
	};

	function initTopicData() {
		curClients = [];

		curClientsName = [];
		curClientsMsgSize = [];
		curClientsMsgPublishCount = [];
	}

	// 차트 초기 데이터 세팅
	function initializeData() {
		console.log("initialize data func");

		msgSize = ${msgSize};

		connections = ${connections};

		msgPublishCount = ${msgPublishCount};

		senders = ${senders};

		topics = ${topics};

		components = ${components};

		if (topics[0] != null) {
			console.log("topic is not null");

			initTopicData();

			curTopic = topics[0];
			curClients = curTopic.clients;

			topicMsgSize.push(curTopic.accumulatedMsgSize);

			for (var i = 0; i < curClients.length; i++) {
				curClientsName.push(curClients[i].name);
				curClientsMsgSize.push(curClients[i].accumulatedMsgSize);
				curClientsMsgPublishCount.push(curClients[i].msgPublishCount);
			}

			console.log(curTopic);
			for (var i = 0; i < components.length; i++) {
				console.log(components[i].topic.topic + " " + curTopic.topic);
				if (components[i].topic == curTopic.topic) {
					curComponent = components[i];
					break;
				}
			}
			
			stroke = curComponent.stroke;
			rect = curComponent.rect;
			oval = curComponent.oval;
			text = curComponent.text;
			image = curComponent.image;
		}
		console.log(curComponent);

		Android = ${Android};
		iOS = ${iOS};
	}

	// 사용하는 차트 생성과 차트를 배열에 삽입
	function initializeChart() {
		console.log("chart initialize");

		msgSizeChart = new Chart(document.getElementById("msgSizeChart"), {
			type : 'line',
			data : {
				labels : labels,
				datasets : [ {
					label : 'Msg Size',
					data : msgSize,
					backgroundColor : 'rgb(0,0,0,0)',
					borderColor : 'rgb(22,160,232)',
					borderWidth : 2,
					lineTension : 0,
					pointRadius : 0
				} ]
			},

			options : {
				responsive : true,
				animation : {
					duration : 1000,
					easing : 'linear'
				},
				legend : false,
				scales : {
					xAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : false
						},
						scaleLabel : {
							display : true,
							labelString : 'seconds'
						}
					} ],
					yAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : true
						},
						ticks : {
							beginAtZero: true,
							maxTicksLimit: 5
						},
						scaleLabel : {
							display : true,
							labelString : 'size'
						}
					} ]
				},
				tooltips: {
					mode: 'nearest',
					titleFontSize: 20,
					backgroundColor: 'rgba(255, 255, 255, 0.8)',
					titleFontColor: 'rgb(102, 102, 102)',
					bodyFontColor: 'rgb(102, 102, 102)'
				},
				layout : {
					padding : {
						left : -5,
						right : -5,
						top : -5,
						bottom : 0
					}
				}
			}
		});
		connectionAndSenderChart = new Chart(document
				.getElementById("connectionAndSenderChart"), {
			type : 'line',
			data : {
				labels : labels,
				datasets : [ {
					label : 'Connection',
					data : connections,
					backgroundColor : 'rgb(242,93,93,0.8)',
					borderColor : 'rgb(242,93,93, 0.8)',
					pointRadius : 5,
					pointHoverRadius : 10,
					showLine : false
				}, {
					label : 'Sender',
					data : senders,
					backgroundColor : 'rgb(255,203,102, 0.8)',
					borderColor : 'rgb(255,203,102, 0.8)',
					pointRadius : 5,
					pointHoverRadius : 10,
					showLine : false
				} ]
			},
			options : {
				responsive : true,
				animation : {
					duration : 1000,
					easing : 'linear'
				},
				legend : {
					display : true,
					labels : {
						fontColor : 'rgb(102, 102, 102)'
					}
				},
				scales : {
					xAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : false
						},
						scaleLabel : {
							display : true,
							labelString : 'seconds'
						}
					} ],
					yAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : true
						},
						ticks : {
							beginAtZero: true,
							maxTicksLimit: 5
						},
						scaleLabel : {
							display : true,
							labelString : 'connections & senders'
						}
					} ]
				},
				tooltips: {
					titleFontSize: 20,
					backgroundColor: 'rgba(255, 255, 255, 0.8)',
					titleFontColor: 'rgb(102, 102, 102)',
					bodyFontColor: 'rgb(102, 102, 102)'
				},
				layout : {
					padding : {
						left : -5,
						right : -5,
						top : -5,
						bottom : 0
					}
				}
			}
		});
		msgPublishCountChart = new Chart(document
				.getElementById("msgPublishCountChart"), {
			type : 'line',
			data : {
				labels : labels,
				datasets : [ {
					data : msgPublishCount,
					steppedLine : true,
					backgroundColor : 'rgb(22,160,232, 0.1)',
					borderColor : 'rgb(22,160,232)',
					borderWidth : 2,
					lineTension : 0.25,
					pointRadius : 0
				} ]
			},
			options : {
				responsive : true,
				animation : {
					duration : 500,
					easing : 'linear'
				},
				legend : false,

				scales : {
					xAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : false
						},
						scaleLabel : {
							display : true,
							labelString : 'seconds'
						}
					} ],
					yAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : true
						},
						ticks : {
							beginAtZero: true,
							maxTicksLimit: 5
						},
						scaleLabel : {
							display : true,
							labelString : 'publish count'
						}
					} ]
				},
				layout : {
					padding : {
						left : -5,
						right : -5,
						top : -5,
						bottom : 0
					}
				}
			}
		});

		componentChart = new Chart(document.getElementById("componentChart"), {
			type : 'bar',
			data : {
				labels : [ 'Stroke', 'Rect', 'Oval', 'Text', 'Image' ],
				datasets : [ {
					data : [ stroke, rect, oval, text, image ],
					backgroundColor : [ 'rgb(241,178,235)','rgb(164,160,252)',
							'rgb(255,203,101)', 'rgb(22,160,232)',
							'rgb(242,93,93)' ]
				} ]
			},
			options : {
				responsive : true,
				animation : {
					duration : 1000,
					easing : 'linear'
				},
				legend : false,
				scales : {
					xAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : false
						},
						scaleLabel : {
							display : true,
							labelString : 'kind of component'
						}
					} ],
					yAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : true
						},
						ticks : {
							beginAtZero: true,
							maxTicksLimit: 5
						},
						scaleLabel : {
							display : true,
							labelString : 'component count'
						}
					} ]
				}
			}
		});

		clientMsgSizeChart = new Chart(document
				.getElementById("clientMsgSizeChart"), {
			type : 'pie',
			data : {
				datasets : [ {
					data : curClientsMsgSize,
					backgroundColor : [ 'rgb(95,227,161)', 'rgb(22,160,232)',
							'rgb(241,178,235)', 'rgb(255,203,101)',
							'rgb(255,203,102)' ]
				} ],
				labels : curClientsName
			},
			options : {
				responsive : true,
				animation : {
					duration : 1000,
					easing : 'linear'
				},
			}
		});

		clientMsgPublishCountChart = new Chart(document
				.getElementById("clientMsgPublishCountChart"), {
			type : 'doughnut',
			data : {
				datasets : [ {
					data : curClientsMsgPublishCount,
					backgroundColor : [ 'rgb(95,227,161)', 'rgb(22,160,232)',
							'rgb(241,178,235)', 'rgb(255,203,101)',
							'rgb(255,203,102)' ]
				} ],
				labels : curClientsName
			},
			options : {
				responsive : true,
				animation : {
					duration : 0,
					easing : 'linear'
				}
			}
		});

		topicMsgSizeChart = new Chart(document
				.getElementById("topicMsgSizeChart"), {
			type : 'line',
			data : {
				labels : labels,
				datasets : [ {
					data : topicMsgSize,
					backgroundColor : 'rgb(0,0,0,0)',
					borderColor : 'rgb(255,99,132)',
					borderWidth : 2,
					lineTension : 0,
					pointRadius : 0
				} ]
			},
			options : {
				responsive : true,
				animation : {
					duration : 1000,
					easing : 'linear'
				},
				legend : false,
				scales : {
					xAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : false
						},
						scaleLabel : {
							display : true,
							labelString : 'seconds'
						}
					} ],
					yAxes : [ {
						gridLines : {
							display : true,
							drawBorder : true,
							drawOnChartArea : true
						},

						ticks : {
							beginAtZero: true,
							maxTicksLimit: 5
						},
						scaleLabel : {
							display : true,
							labelString : 'size'
						}
					} ]
				},
				layout : {
					padding : {
						left : -5,
						right : -5,
						top : -5,
						bottom : 0
					}
				}
			}
		});

	}

	function updateCharts() {
		console.log("update charts");

		msgSizeChart.update();
		connectionAndSenderChart.update();
		msgPublishCountChart.update();

		componentChart.data.datasets[0].data = [ stroke, rect, oval, text, image ];
		componentChart.update();

		clientMsgPublishCountChart.data.datasets[0].data = curClientsMsgPublishCount;
		clientMsgPublishCountChart.data.labels = curClientsName;
		clientMsgPublishCountChart.update();

		topicMsgSizeChart.data.datasets[0].data = topicMsgSize;
		topicMsgSizeChart.update();
		
		clientMsgSizeChart.data.datasets[0].data = curClientsMsgSize;
		clientMsgSizeChart.data.labels = curClientsName;
		clientMsgSizeChart.update();

	}
	

	function printDuration() {

		// 현재 사용중인 토픽이 없거나(토픽 배열이 빈 상태), 테이블 업데이트가 이루어지지 않은 경우(행과 열이 생성되지 않은 상태)
		if(document.getElementById('topicTable').rows.length - 1 != topics.length) {
			for (var i = 0; i < topics.length; i++) {
				durations[i] = '0:0:0';
			}
			return;
		}
		
		durations = [];
		for (var i = 0; i < topics.length; i++) {

			var diff = Math.abs(new Date()
					- new Date(topics[i].startDate.replace(/-/g, '/')));
			console.log(diff);

			var duration = msToTime(diff);

			durations.push(duration); // function updateTopicTable() 에서 반영하기 위해
			document.getElementById('topicTable').rows[i + 1].cells[4].innerHTML = duration;
		}

	}

	function updateTopicTable() {
		console.log("update topic topic table");
		
		var topicTable = document.getElementById('topicTable');
		var topicTableBody = document.getElementById('topicTableBody');

		topicTableBody.innerHTML = "";

		var rows = '';

		for (var i = 0; i < topics.length; i++) {
			rows += '<tr>';
			rows += '<th scope="row">' + (i + 1) + '</th>';
			rows += '<td>' + topics[i].topic + '</td>';
			rows += '<td>' + topics[i].startDate + '</td>';
			rows += '<td>' + topics[i].participants + '</td>';
			rows += '<td>' + durations[i] + '</td>';
			rows += '</tr>';
		}

		topicTableBody.innerHTML = rows;

		var rows = document.getElementsByTagName('tr');
		for (var i = 0; i < rows.length; i++) {
			rows[i].addEventListener('click', function() {
				var cell = this.getElementsByTagName('td')[0];

				if (curTopic.topic == cell.innerHTML) {
					return;
				}

				for (var i = 0; i < topics.length; i++) {
					if (topics[i].topic == cell.innerHTML) {
						curTopic = topics[i];
						topicMsgSize = [];
						break;
					}
				}
			});
		}

	}

	function updateTotalAmountLabel() {
		console.log("update total amount");

		var androidLabel = document.getElementById('androidLabel');
		androidLabel.innerHTML = Android;

		var iOSLabel = document.getElementById('iOSLabel');
		iOSLabel.innerHTML = iOS;

	}

	function shiftArrays() {

		console.log("-------------------- length --------------------");
		console.log("msgSize = " + msgSize.length + ", topicMsgSize = "
				+ topicMsgSize.length + ", labels = " + labels.length);

		if (msgSize.length > labels.length) {
			console.log("advance func shift (total data)");

			msgSize.shift();
			connections.shift();
			senders.shift();
			msgPublishCount.shift();
		}

		if (topicMsgSize.length > labels.length) {
			console.log("advance func shift (topicMsgSize)");

			topicMsgSize.shift();
		}

		/* setTimeout(function() {
			requestAnimationFrame(shiftArrays);
		}, 1000); */
	}

	function startTimer() {
		setInterval(printDuration, 1000);
	}

	function getData() {
		var es = new EventSource("http://localhost:8080/Dashboard/update");

		es.onopen = function(evt) {
			console.log("connection success!!");
		}

		es.onerror = function(evt) {
			console.log("occur error!!");
		}

		es.onmessage = function(evt) {
			console.log("getData func");

			var obj = JSON.parse(evt.data);
			console.log(evt.data);

			// 서버로부터 받은 데이터 저장
			msgSize.push(obj.realtime.accumulatedMsgSize);
			connections.push(obj.realtime.numberOfConnections);
			msgPublishCount.push(obj.realtime.msgPublishCount);
			senders.push(obj.realtime.numberOfSenders);

			topics = obj.topics;
			components = obj.components;

			Android = parseInt(obj.platformMap.Android);
			iOS = parseInt(obj.platformMap.iOS);

			shiftArrays();

			if (topics.length != 0) {
				if (topics.length == 1) {
					console.log("topic is not null");

					initTopicData();

					curTopic = topics[0];
					curClients = curTopic.clients;

					topicMsgSize.push(curTopic.accumulatedMsgSize);
				}

				else {
					for (var i = 0; i < topics.length; i++) {

						if (topics[i].topic == curTopic.topic) { // fixme topic이 아무것도 없다가 생겼을 경우

							initTopicData();

							curTopic = topics[i];
							curClients = curTopic.clients;

							topicMsgSize.push(curTopic.accumulatedMsgSize);

							break;
						}
					}
				}

				for (var i = 0; i < curClients.length; i++) {
					curClientsName.push(curClients[i].name);
					curClientsMsgSize.push(curClients[i].accumulatedMsgSize);
					curClientsMsgPublishCount
							.push(curClients[i].msgPublishCount);
				}

				console.log(curTopic);
				for (var i = 0; i < components.length; i++) {
					if (components[i].topic.topic == curTopic.topic) {
						curComponent = components[i];
						break;
					}
				}

				stroke = curComponent.stroke;
				rect = curComponent.rect;
				oval = curComponent.oval;
				text = curComponent.text;
				image = curComponent.image;
			}

			updateCharts();
			updateTopicTable();
			updateTotalAmountLabel();

		}

	}

	function msToTime(s) {
		var ms = s % 1000;
		s = (s - ms) / 1000;
		var secs = s % 60;
		s = (s - secs) / 60;
		var mins = s % 60;
		var hrs = (s - mins) / 60;

		return hrs + ':' + mins + ':' + secs;
	}
</script>

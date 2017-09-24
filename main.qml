import QtQuick 2.4
import QtCanvas3D 1.1
import QtQuick.Window 2.2

import QtQuick.Scene3D 2.0
import QtQuick.Layouts 1.2
import QtMultimedia 5.0

import "glcode.js" as GLCode

//  全局界面定义
Item {
    id: mainview
    
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight-40
    visible: true
    //  property    定义一个属性
    property bool isHoverEnabled: false
    
    
    //
    property variant magnitudeArray: null
    property int millisecondsPerBar: 68
    property string magnitudeDataSourceFile: "qrc:/music/visualization.raw"
    property int mediaLatencyOffset: 68
    
    //  定义此过程中的四种状态
    state: "stopped"
    states: [
        State {
            name: "playing"
            PropertyChanges {
                target: playButtonImage
                source: {
                    if (playButtonMouseArea.containsMouse)
                        "qrc:/images/pausehoverpressed.png"
                    else
                        "qrc:/images/pausenormal.png"
                }
            }
            PropertyChanges {
                target: stopButtonImage
                source: "qrc:/images/stopnormal.png"
            }
        },
        State {
            name: "paused"
            //  使一个按钮state的属性发生改变
            PropertyChanges {
                target: playButtonImage
                source: {
                    if (playButtonMouseArea.containsMouse)
                        "qrc:/images/playhoverpressed.png"
                    else
                        "qrc:/images/playnormal.png"
                }
            }
            PropertyChanges {
                target: stopButtonImage
                source: "qrc:/images/stopnormal.png"
            }
        },
        State {
            name: "stopped"
            PropertyChanges {
                target: playButtonImage
                source: "qrc:/images/playnormal.png"
            }
            PropertyChanges {
                target: stopButtonImage
                source: "qrc:/images/stopdisabled.png"
            }
        }
    ]
    
    //  判断鼠标是否可用
    Component.onCompleted: isHoverEnabled = touchSettings.isHoverEnabled()

    //  媒体播放器部分
    //![0]
    MediaPlayer {
        id: mediaPlayer
        autoPlay: true
        volume: 0.5
        source: "qrc:/music/tiltshifted_lost_neon_sun.mp3"
        //![0]

        onStatusChanged: {
            if (status == MediaPlayer.EndOfMedia) //{
                state = "stopped"
        }

        onError: console.error("error with audio " + mediaPlayer.error)

        onDurationChanged: {
            //  XMLHttpRequest
            //  在不重新加载页面的情况下更新网页
            //  在页面已加载后从服务器请求数据
            //  在页面已加载后从服务器接收数据
            //  在后台向服务器发送数据
            // Load the pre-calculated magnitude data for the visualizer
            var request = new XMLHttpRequest()
            request.responseType = 'arraybuffer'
            request.onreadystatechange = function() {
                    if (request.readyState === XMLHttpRequest.DONE) {
                        if (request.status == 200 || request.status == 0) {
                            var arrayBuffer = request.response
                            if (arrayBuffer) {
                                magnitudeArray = new Uint16Array(arrayBuffer)
                                visualizer.startVisualization()
                              }
                        } else {
                            console.warn("Couldn't load magnitude data for bars.")
                        }
                        request = null
                    }
                };

            request.open('GET', magnitudeDataSourceFile, true)
            request.send(null)
        }
        
        //  从数组magnitudeArray中获取下一个梯形框 
        function getNextAudioLevel(offsetMs) {
            if (magnitudeArray === null)
                return 0.0;
            
            //计算数据中的当前索引位置在数组中值的大小
            // Calculate the integer index position in to the magnitude array
            var index = ((mediaPlayer.position + offsetMs) /
                         mainview.millisecondsPerBar) | 0;

            if (index < 0 || index >= magnitudeArray.length)
                return 0.0;

            return (magnitudeArray[index] / 63274.0);
        }
    }

    Image {
        id: coverImage
        anchors.fill: parent
        source: "qrc:/images/albumcover.png"
    }

    //![1]
    Scene3D {
        anchors.fill: parent

        Visualizer {
            id: visualizer
            animationState: mainview.state
            numberOfBars: 120
            barRotationTimeMs: 8160 // 68 ms per bar
        }
    }
    //![1]

    Rectangle {
        id: blackBottomRect
        color: "black"
        width: parent.width
        height: 0.14 * mainview.height
        anchors.bottom: parent.bottom
    }

    //  显示已经播放的时间
    // Duration of played content
    Text {
        text: formatDuration(mediaPlayer.position)
        color: "#80C342"
        x: parent.width / 6
        y: mainview.height - mainview.height / 8
        font.pixelSize: 12
    }
    
    //  显示剩余播放的时间
    // Duration of the content left
    Text {
        text: "-" + formatDuration(mediaPlayer.duration - mediaPlayer.position)
        color: "#80C342"
        x: parent.width - parent.width / 6
        y: mainview.height - mainview.height / 8
        font.pixelSize: 12
    }
    //  运用JavaScript时间格式转换函数：传入微秒转化为整数（分钟+秒数）形式返回
    //  把微秒数转化为分钟数并取整
    //  然后再将取整后的分钟数转化为微秒
    function formatDuration(milliseconds) {
        var minutes = Math.floor(milliseconds / 60000)
        milliseconds -= minutes * 60000
        //  将微秒转化为秒
        var seconds = milliseconds / 1000
        //  将转化后的秒数舍入为最接近的整数秒
        seconds = Math.round(seconds)
        if (seconds < 10)
            return minutes + ":0" + seconds
        else
            return minutes + ":" + seconds
    }
    
    //  设置水平方向距离为10
    property int buttonHorizontalMargin: 10
    //  播放按钮
    Rectangle {
        id: playButton
        height: 54
        width: 54
        anchors.bottom: parent.bottom
        anchors.bottomMargin: width
        x: parent.width / 2 - width - buttonHorizontalMargin
        color: "transparent"

        Image {
            id: playButtonImage
            source: "qrc:/images/pausenormal.png"
        }

        //  
        MouseArea {
            id: playButtonMouseArea
            anchors.fill: parent
            hoverEnabled: isHoverEnabled
            onClicked: {
                if (mainview.state == 'paused' || mainview.state == 'stopped')
                    mainview.state = 'playing'
                else
                    mainview.state = 'paused'
            }
            onEntered: {
                if (mainview.state == 'playing')
                    playButtonImage.source = "qrc:/images/pausehoverpressed.png"
                else
                    playButtonImage.source = "qrc:/images/playhoverpressed.png"
            }
            onExited: {
                if (mainview.state == 'playing')
                    playButtonImage.source = "qrc:/images/pausenormal.png"
                else
                    playButtonImage.source = "qrc:/images/playnormal.png"
            }
        }
    }
    //  停止按钮
    Rectangle {
        id: stopButton
        height: 54
        width: 54
        anchors.bottom: parent.bottom
        anchors.bottomMargin: width
        x: parent.width / 2 + buttonHorizontalMargin
        color: "transparent"

        Image {
            id: stopButtonImage
            source: "qrc:/images/stopnormal.png"
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: isHoverEnabled
            onClicked: mainview.state = 'stopped'
            onEntered: {
                if (mainview.state != 'stopped')
                    stopButtonImage.source = "qrc:/images/stophoverpressed.png"
            }
            onExited: {
                if (mainview.state != 'stopped')
                    stopButtonImage.source = "qrc:/images/stopnormal.png"
            }
        }
    }
}


/**
  *
  *
Window {
    title: qsTr("Audio")
    width: 1280
    height: 700
    visible: true
    
    Canvas3D {
        id: canvas3d
        anchors.fill: parent
        focus: true
        
        onInitializeGL: {
            GLCode.initializeGL(canvas3d);
        }
        
        onPaintGL: {
            GLCode.paintGL(canvas3d);
        }
        
        onResizeGL: {
            GLCode.resizeGL(canvas3d);
        }
    }
}

*/

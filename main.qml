// Copyright (C) 2022 Kambiz Asadzadeh
// SPDX-License-Identifier: LGPL-3.0-only

import QtQuick
import QtQuick.Window
import QtQuick.Controls.Basic
import QtQuick.Layouts

ApplicationWindow {
    id: appRoot
    width: 420
    height: 290
    visible: true
    title: qsTr("eWeather")

    QtObject {
        id: appObject
        readonly property string apiUrl : "http://api.openweathermap.org/geo/1.0/direct?q="; //From https://openweathermap.org
        readonly property string weatherApiUrl : "https://api.openweathermap.org/data/2.5/weather?"; //From https://openweathermap.org
        readonly property string apiKey : "8a25f223e60c89f2987f69916dcf0a99";
        readonly property string method : "GET";

        property double lon : 0.0;
        property double lat : 0.0;
        property string icon;
        property string main: "";
        property string description: " ";

        property double speed: 0.0;
        property double deg: 0.0;
        property double temp : 0.0;
        property double feels_like : 0.0;
        property double pressure : 0.0;
        property int humidity: 0;

        property bool isCelsius : unitType.checked ? true : false

    }

    function dataRequest(type)
    {
        var req = new XMLHttpRequest();
        req.open(appObject.method, appObject.apiUrl + cityValue.text + "&limit=1&appid=" + appObject.apiKey);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                let result = JSON.parse(req.responseText);
                //Data
                appObject.lat = JSON.stringify(result[0].lat);
                appObject.lon = JSON.stringify(result[0].lon);
                //Information
                {
                    console.log("lat: " + JSON.stringify(result[0].lat))
                    console.log("lon: " + JSON.stringify(result[0].lon))
                }
                weatherRequest();
            }
        }
        req.onerror = function(){
            console.log("Error!")
        }
        req.send()
    }

    //! Remove extra double quote for some json outputs.
    function stringFixer(variable)
    {
        return variable.replace(/['"]+/g, '')
    }

    function weatherRequest()
    {
        var req = new XMLHttpRequest();
        var unit = appObject.isCelsius ? "metric" : "imperial";
        req.open(appObject.method, appObject.weatherApiUrl + "lat="+appObject.lat+"&lon="+appObject.lon+"&units=" + unit + "&exclude=hourly,daily&appid=" + appObject.apiKey);
        req.onreadystatechange = function() {
            if (req.readyState === XMLHttpRequest.DONE) {
                let result = JSON.parse(req.responseText);
                appObject.icon          = JSON.stringify(result.weather[0].icon)
                appObject.main          = JSON.stringify(result.weather[0].main)
                appObject.description   = JSON.stringify(result.weather[0].description)
                appObject.humidity      = JSON.stringify(result.main.humidity)
                appObject.feels_like    = JSON.stringify(result.main.feels_like)
                appObject.pressure      = JSON.stringify(result.main.pressure)
                appObject.temp          = JSON.stringify(result.main.temp)
                appObject.speed         = JSON.stringify(result.wind.speed)
                appObject.deg           = JSON.stringify(result.wind.deg)

                var icon = "qrc:/resources/icons/";
                icon+= appObject.icon;
                icon+="@2x.png";
                iconImage.source = icon.replace(/['"]+/g, '');
                busyIndicator.running = false;
            }
        }
        req.onerror = function(){
            console.log("Error!")
        }
        req.send()
    }

    Pane {
        width: parent.width
        Layout.fillWidth: true
        ColumnLayout {
            width: parent.width
            Layout.fillWidth: true
            spacing: 10
            TextField {
                id: cityValue
                width: parent.width
                height: 32
                Layout.fillWidth: true
                placeholderText: "Enter city name"
                background: Rectangle {
                    height: 32
                    border.width: cityValue.focus ? 2 : 1
                    border.color: "#276fff"
                    radius: 5
                }
            }
            RowLayout {
                spacing: 10
                width: parent.width
                Layout.fillWidth: true
                Button {
                    id: control
                    width: 140
                    height: 48
                    Layout.fillWidth: true
                    text: "Get Data"
                    background: Rectangle {
                        height: 48
                        color: "#276fff"
                        anchors.fill: parent
                        radius: 5
                    }
                    contentItem: Text {
                        text: control.text
                        font: control.font
                        opacity: enabled ? 1.0 : 0.3
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        scale: control.down ? 0.9 : 1.0
                        Behavior on scale {
                            NumberAnimation {duration: 70;}
                        }
                    }

                    onClicked: {
                        if(cityValue.text !== "") {
                            busyIndicator.running = true;
                            dataRequest();
                        }
                    }
                }
                Text {
                    font.pixelSize: 12
                    font.bold: true
                    text: qsTr("Fahrenheit")
                }
                Switch {
                    id: unitType
                    width: 64
                    indicator: Rectangle {
                             implicitWidth: 48
                             implicitHeight: 26
                             x: unitType.leftPadding
                             y: parent.height / 2 - height / 2
                             radius: 13
                             color: unitType.checked ? "#276fff" : "#ffffff"
                             border.color: unitType.checked ? "#276fff" : "#cccccc"

                             Rectangle {
                                 x: unitType.checked ? parent.width - width : 0
                                 width: 26
                                 height: 26
                                 radius: 13
                                 color: unitType.down ? "#cccccc" : "#ffffff"
                                 border.color: unitType.checked ? (unitType.down ? "#276fff" : "#276fff") : "#999999"
                             }
                         }

                         contentItem: Text {
                             text: unitType.text
                             font: unitType.font
                             opacity: enabled ? 1.0 : 0.3
                             color: unitType.down ? "#276fff" : "#21be2b"
                             verticalAlignment: Text.AlignVCenter
                             leftPadding: unitType.indicator.width + unitType.spacing
                         }
                }
                Text {
                    font.pixelSize: 12
                    font.bold: true
                    text: qsTr("Celsius")
                }
            }
            ColumnLayout {
                width: parent.width
                Layout.fillWidth: true

                Text {
                    font.pixelSize: 16
                    font.bold: true
                    text: qsTr("Wind")
                }
                RowLayout {
                    spacing: 25
                    width: parent.width
                    Layout.fillWidth: true
                    Text {
                        font.pixelSize: 14
                        font.bold: false
                        text: qsTr("Speed: " + appObject.speed)
                    }
                    Text {
                        font.pixelSize: 14
                        font.bold: false
                        text: qsTr("Deg: " + appObject.deg)
                    }
                    Item {
                        width: 64
                        height: 64
                        Image {
                            id: iconImage
                            width: 64
                            height: 64
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                    Column {
                        spacing: 5
                        Text {
                            font.pixelSize: 24
                            font.bold: true
                            text: qsTr(stringFixer(appObject.main))
                        }
                        Text {
                            font.pixelSize: 14
                            font.bold: false
                            font.capitalization: Font.AllUppercase
                            text: qsTr(stringFixer(appObject.description))
                        }
                    }
                }

                ///
                Text {
                    font.pixelSize: 16
                    font.bold: true
                    text: qsTr("Main")
                }

                Item { height: 20; }

                Row {
                    spacing: 25
                    Row {Text {
                            font.pixelSize: 14
                            font.bold: false
                            text: qsTr("Temp: " + appObject.temp)
                        }
                        Text {
                            font.pixelSize: 10
                            font.bold: true
                            text: qsTr(appObject.isCelsius ? "°C" : "°F")
                            y: -10
                        }
                    }
                    Text {
                        font.pixelSize: 14
                        font.bold: false
                        text: qsTr("Pressure: " + appObject.pressure)
                    }
                    Text {
                        font.pixelSize: 14
                        font.bold: false
                        text: qsTr("Humidity: " + appObject.humidity)
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        running: false
    }
}

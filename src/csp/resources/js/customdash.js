var urlOrigin = window.location.origin;
var urlREST = urlOrigin + "/csp/irisapp/api";

$(document).ready(function () {


  $.getJSON(urlREST + "/global/header", function (response) {
    $("#idTotalVaccines").text(response.totalVaccine);
    $("#idTotalCountry").text(response.totalCountries);
    $("#idTotal").text(response.totalVaccination.toLocaleString());
  });

  $.getJSON(urlREST + "/global/topvacbycountry", function (response) {

    var options = {
      chart: {
        height: 380,
        width: "100%",
        type: "line"
      },
      stroke: {
        show: true,
        curve: 'smooth'
      },
      series: response,
      xaxis: {
        type: "datetime"
      }
    };

    var chart = new ApexCharts(document.querySelector("#chartline"), options);

    chart.render();
  });

  $.getJSON(urlREST + "/global/toppercentvacbycountry", function (response) {

    var options = {
      theme: {
        palette: 'palette8' // upto palette10
      },
      chart: {
        height: 380,
        width: "100%",
        size: 1,
        type: "line"
      },
      stroke: {
        show: true,
        curve: 'smooth'
      },
      series: response,
      xaxis: {
        type: "datetime"
      }
    };

    var chart = new ApexCharts(document.querySelector("#chartlineperc"), options);

    chart.render();
  });


  $.getJSON(urlREST + "/global/topvacbarchart", function (response) {

    var chart4 = new ApexCharts(document.querySelector("#apexchart-4"), {
      series: [{
        name: "Total Vaccinations",
        data: response[0]
      }],
      chart: {
        type: "bar"
      },
      plotOptions: {
        bar: {
          horizontal: true
        }
      },
      dataLabels: {
        enabled: false
      },
      xaxis: {
        categories: response[1]
      }
    });

    chart4.render();

  });

  $.getJSON(urlREST + "/global/tophighbarchart", function (response) {

    var chart4 = new ApexCharts(document.querySelector("#barchartperc"), {
      series: [{
        name: "% Population Vaccinations",
        data: response[0]
      }],
      theme: {
        mode: 'light',
        palette: 'palette8'
      },
      chart: {
        type: "bar"
      },
      plotOptions: {
        bar: {
          horizontal: true
        }
      },
      dataLabels: {
        enabled: false
      },
      xaxis: {
        categories: response[1]
      }
    });

    chart4.render();

  });



  $.getJSON(urlREST + "/global/vaccineperc", function (response) {
    var chart8 = new ApexCharts(document.querySelector("#piechart"), {
      series: response[0],
      chart: {
        type: "pie"
      },
      colors: ['#f51720',
      '#fa26a0',
      '#f8d210',
      '#2ff3e0',
      '#e1c340',
      '#4cd7d0',
      '#a4e8e0',
      '#f8ea8c',
      '#146c80',
      '#22aac0',
      '#c3b330',
      '#d23130'],
      labels: response[1],
      tooltip: {
        fillSeriesColor: false
      },
      responsive: [{
        breakpoint: 480,
        options: {
          chart: {
            width: 200
          },
          legend: {
            position: "bottom"
          }
        }
      }]
    });

    chart8.render();
  });



});
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
      colors: ['#0000ff', '#71008e', '#e3001c', '#ff5500', '#ffc600', '#fff12d', '#ffd587', '#e3b9b4', '#719c5a', '#008000'],
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
      colors: ['#0000ff', '#71008e', '#e3001c', '#ff5500', '#ffc600', '#fff12d', '#ffd587', '#e3b9b4', '#719c5a', '#008000'],
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
      colors: ['#0000ff', '#71008e', '#e3001c', '#ff5500', '#ffc600', '#fff12d', '#ffd587', '#e3b9b4', '#719c5a', '#008000'],
      labels: response[1],
      tooltip: {
        fillSeriesColor: false
      },
      responsive: [{
        breakpoint: 480,
        options: {
          chart: {
            width: 350
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
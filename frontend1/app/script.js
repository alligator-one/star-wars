const API_ENDPOINT = "/api/"

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function update() { // /api/update method
    $.get(API_ENDPOINT + "update")
    $("#update").text("Started Update")
    sleep(1000).then(function () {
        $("#update").text("Update")
    })
}

function personsTable(data) { // generate <table> from /api/persons
    let table = "<table class=\"table\"><thead><tr><th scope=\"col\">Name</th><th scope=\"col\">Gender</th><th scope=\"col\">Homeworld</th><th scope=\"col\">Starships</th></tr></thead><tbody>"
    data["result"].forEach(function (person) {
        table += "<tr>"
        table += "<td>" + person["name"] + "</td>"
        table += "<td>" + person["gender"] + "</td>"
        table += "<td>" + person["homeworld"]["name"] + "</td>"
        table += "<td><table class=\"table table-bordered m-0\"><thead><tr><th>Name</th><th>Model</th><th>Manufacturer</th><th>Cost</th><th>Length</th><th>Crew</th><th>Cargo</th><th>Class</th></tr></thead><tbody>"
        if (person["starships"] !== undefined) {
            person["starships"].forEach(function (starship) {
                table += "<tr>"
                table += "<td>" + starship["name"] + "</td>"
                table += "<td>" + starship["model"] + "</td>"
                table += "<td>" + starship["manufacturer"] + "</td>"
                table += "<td>" + starship["cost_in_credits"] + "</td>"
                table += "<td>" + starship["length"] + "</td>"
                table += "<td>" + starship["crew"] + "</td>"
                table += "<td>" + starship["cargo"] + "</td>"
                table += "<td>" + starship["starship_class"] + "</td>"
                table += "</tr>"
            })
        }
        table += "</tbody></table></td>"
        table += "</tr>"
    })
    table += "</tbody></table>"
    return table
}

function starshipsTable(data) { // generate <table> from /api/starships
    let table = "<table class=\"table\"><thead><tr><th>Name</th><th>Model</th><th>Manufacturer</th><th>Cost</th><th>Length</th><th>Crew</th><th>Cargo</th><th>Class</th><th>Pilots</th></tr></thead><tbody>"
    data["result"].forEach(function (starship) {
        table += "<tr>"
        table += "<td>" + starship["name"] + "</td>"
        table += "<td>" + starship["model"] + "</td>"
        table += "<td>" + starship["manufacturer"] + "</td>"
        table += "<td>" + starship["cost_in_credits"] + "</td>"
        table += "<td>" + starship["length"] + "</td>"
        table += "<td>" + starship["crew"] + "</td>"
        table += "<td>" + starship["cargo"] + "</td>"
        table += "<td>" + starship["starship_class"] + "</td>"
        table += "<td><table class=\"table table-bordered m-0\"><thead><tr><th>Name</th><th>Gender</th><th>Homeworld</th></tr></thead><tbody>"
        if (starship["pilots"] !== undefined) {
            starship["pilots"].forEach(function (person) {
                table += "<tr>"
                table += "<td>" + person["name"] + "</td>"
                table += "<td>" + person["gender"] + "</td>"
                table += "<td>" + person["homeworld"]["name"] + "</td>"
                table += "</tr>"
            })
        }
        table += "</tbody></table></td>"
        table += "</tr>"
    })
    table += "</tbody></table>"
    return table
}

function report() { // Generate report
    let count = $("#report-count").val() // how much to get
    $.ajax({
        url: API_ENDPOINT + "report",
        type: "get",
        data: {
            "count": count
        },
        error: function (err) {
            document.getElementById("report-contents").innerHTML = "<h1>Error: " + err.data + "</h1>"
        }
    }).done(function (data) {
        if (data["error"] == null) {
            document.getElementById("report-contents").innerHTML = personsTable(data)
        } else {
            document.getElementById("report-contents").innerHTML = "<h1>Error: " + data["error"] + "</h1>"
        }
    })
}

function persons() { // /api/persons
    let count = $("#person-count").val() // how much to get
    $.ajax({
        url: API_ENDPOINT + "persons",
        type: "get",
        data: {
            "count": count
        },
        error: function (err) {
            document.getElementById("person-contents").innerHTML = "<h1>Error: " + err.data + "</h1>"
        }
    }).done(function (data) {
        if (data["error"] == null) {
            document.getElementById("person-contents").innerHTML = personsTable(data)
        } else {
            document.getElementById("person-contents").innerHTML = "<h1>Error: " + data["error"] + "</h1>"
        }
    })
}

function starships() { // /api/starships
    let count = $("#starship-count").val() // how much to get
    $.ajax({
        url: API_ENDPOINT + "starships",
        type: "get",
        data: {
            "count": count
        },
        error: function (err) {
            document.getElementById("starship-contents").innerHTML = "<h1>Error: " + err.data + "</h1>"
        }
    }).done(function (data) {
        if (data["error"] == null) {
            document.getElementById("starship-contents").innerHTML = starshipsTable(data)
        } else {
            document.getElementById("starship-contents").innerHTML = "<h1>Error: " + data["error"] + "</h1>"
        }
    })
}

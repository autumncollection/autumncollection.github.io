
function loadData() {
    var xhttp = new XMLHttpRequest();
    var a = document.getElementById("search").value;
    xhttp.onreadystatechange=function() {
      if (this.readyState == 4 && this.status == 200) {
        document.getElementById("data").innerHTML = this.responseText;
      }
    };
    xhttp.open("GET", "/find?what=" + a, true);
    xhttp.send();
}
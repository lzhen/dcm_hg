
var b1dis = "<a href=\"";
var bdis = " <img src=\"";
var edis = " width=\"1000\" height=\"210\" alt=\"image\" border=\"0\"><\/a>";
var rnumb = "";
var img = "";

rnumb += Math.floor(Math.random()*5);
img = rnumb;

if (img == "0") {
document.write(bdis+ "http://herbergerinstitute.asu.edu/degrees/digital_culture/photos/ame1.jpg\"" +edis);
}
if (img == "1") {
document.write(bdis+ "http://herbergerinstitute.asu.edu/degrees/digital_culture/photos/ame2.jpg\"" +edis);
}
if (img == "2") {
document.write(bdis+ "http://herbergerinstitute.asu.edu/degrees/digital_culture/photos/ame3.jpg\"" +edis);
}
if (img == "3") {
document.write(bdis+ "http://herbergerinstitute.asu.edu/degrees/digital_culture/photos/ame4.jpg\"" +edis);
}
if (img == "4") {
document.write(bdis+ "http://herbergerinstitute.asu.edu/degrees/digital_culture/photos/ame5.jpg\"" +edis);
}

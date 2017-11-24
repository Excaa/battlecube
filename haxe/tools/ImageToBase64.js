/**
 * Node.js tool to generate assets.
 * @author Henri Sarasvirta
 */
 
// print process.argv
var config = {
	input : "../assets/img/",
	output: "../bin/assets.js",
	includeExtension: true
};
for(var i = 2; i < process.argv.length; i++)
{
	var v = process.argv[i];
	switch(v)
	{
		case "-o":
		case "-output":
			config.output = process.argv[i+1];
			break;
		case "-i":
		case "-input":
			config.input = process.argv[i+1];
			break;
		case "-e":
		case "-extension":
			config.includeExtension = process.argv[i+1].toLowerCase() == "true";
			break;
		default:
			break;
	}
}
console.log("reading " + config.input);

var fs = require('fs');

var inStat = fs.statSync(config.input);
var files = [];
if(inStat.isDirectory())
{
	files = fs.readdirSync(config.input);
}
else
{
	files = [config.input];
}
var output = "(function(){\n";

for(var i = 0; i < files.length; i++)
{
	var filename = files[i];
	var id = config.includeExtension ? filename:
      	                               filename.substr( 0, filename.lastIndexOf(".") ); 
	console.log("open file " + filename + " id " + id);
	var data = fs.readFileSync(config.input+"/"+filename);
	var base64 = data.toString("base64");
	var type = filename.substr(filename.lastIndexOf(".")+1);
	output += 'kvg.core.assets.register("' +id +'","'+type +'","'+base64+'");\n';
}
output += "}())\n";

fs.writeFileSync(config.output, output);
console.log("Complete");
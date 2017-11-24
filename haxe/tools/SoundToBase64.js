/**
 * Node.js tool to generate assets.
 * @author Henri Sarasvirta
 */
 
// print process.argv
var config = {
	input_ogg : "../bin/bg.ogg",
	input_mp3 : "../bin/bg.mp3",
	output: "../bin/assets_sound.js",
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
		case "-i_ogg":
		case "-input_ogg":
			config.input_ogg = process.argv[i+1];
			break;
		case "-i_mp3":
		case "-input_mp3":
			config.input_mp3 = process.argv[i+1];
			break;
		case "-e":
		case "-extension":
			config.includeExtension = process.argv[i+1].toLowerCase() == "true";
			break;
		default:
			break;
	}
}
console.log("reading " + config.input_ogg);

var fs = require('fs');
var isFile = false;
var inStat = fs.statSync(config.input_ogg);
var files = [];
if(inStat.isDirectory())
{
	files = fs.readdirSync(config.input_ogg);
}
else
{
	isFile = true;
	files = [config.input_ogg];
}
var inStat = fs.statSync(config.input_mp3);
if(inStat.isDirectory())
{
	files = files.concat(fs.readdirSync(config.input_mp3));
}
else
{
	isFile = true;
	files.push(config.input_mp3);
}

var output = "(function(){\n";

for(var i = 0; i < files.length; i++)
{
	var filename = files[i];
	var id = config.includeExtension ? filename.substr( filename.lastIndexOf("/")+1):
      	                               filename.substr( filename.substr( filename.lastIndexOf("/")+1, filename.lastIndexOf(".") )); 
	console.log("open file " + filename + " id " + id);
	var data = fs.readFileSync(isFile?filename:(config.input+"/"+filename));
	var base64 = data.toString("base64");
	var type = filename.substr(filename.lastIndexOf(".")+1);
	output += 'kvg.core.assets.register("' +id +'","'+type +'","'+base64+'");\n';
}
output += "}())\n";

fs.writeFileSync(config.output, output);
console.log("Complete");
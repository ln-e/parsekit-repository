# Copyright Art. Lebedev | http://www.artlebedev.ru/
# Author: Vladimir Tokmakov | vlalek
# Updated: 2016-07-13


@CLASS
web_document

@OPTIONS
locals


@create[data;params]
^ref:copy[$params;$self]
$self.data[
	$.system[
		$.@version[15.12]
		$.created[$xml:now]
		$.request[
			$.@method[$env:REQUEST_METHOD]
			$.@uri[$env:REQUEST_URI]
			$.@charset[$request:charset]
			$.@domain[$env:SERVER_NAME]
		]
		$.remote[
			$.@addr[$env:REMOTE_ADDR]
			$.@agent[$env:HTTP_USER_AGENT]
		]
	]
]
^ref:copy[$data;$self.data;$.recursive(true)]


@result[]
$self.data.system.response[
	$.@charset[$response:charset]
	$.@status[$response:status]
]
^if($self.error > 400){
	$request:charset[$response:charset]
	$f[^file::load[text;http://${env:SERVER_NAME}$self.error_path;$.charset[UTF-8]$.any-status(true)]]
	$response:content-type[
		$.value[text/html]
		$.charset[$response:charset]
	]
	$result[^untaint{$f.text}]
}(def $response:location){
	$result[]
}{
	^if($response:[content-type].value eq "text/xml" || ^self.mode[xml]){
		$response:content-type[
			$.value[text/xml]
			$.charset[$response:charset]
		]
		$result[^self.xml[]]
	}($response:[content-type].value eq "application/json" || ^self.mode[json]){
		$response:content-type[
			$.value[application/json]
			$.charset[$response:charset]
		]
		$result[^self.json[]]
	}{
		$response:content-type[
			$.value[text/html]
			$.charset[$response:charset]
		]
		$result[^self.html[]]
	}
}
^if(^self.mode[debug]){
	^debug:show[$self]
}


@json[][result]
^json:string[$self.data;
	$.indent[^if(^MAIN:developer[]){^#09}]
	$._default[$ref:object_json_string]
	$.hash[$ref:hash_json_string]
]


@html[]
$xdoc[^xdoc::create{^self.xml[]}]
$html[^xdoc.transform[^xdoc::load[$self.xsl_path]]]
^html.string[]


@xml[]
^xml:head[$.encoding[$response:charset]$.doctype[^if(^self.mode[xml]){html}]]
^xml:string[$self.data;;document]


@mode[value]
$result($form:tables.mode && ^form:tables.mode.locate[field;$value])


@SET_error[value]
$self._error[$value]
$response:status[$value]


@GET_error[]
$self._error


@GET_error_path[]
/$self._error/

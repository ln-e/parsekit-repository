# Copyright Art. Lebedev | http://www.artlebedev.ru/
# Author: Vladimir Tokmakov | vlalek
# Updated: 2015-07-08


@CLASS
xml

@OPTIONS
static
locals


@auto[]
$xml:now[^date::now[]]
$xml:ncname_pattern[^regex::create[^^[_a-zA-Z][_a-zA-Z0-9]*^$]]


@parse[xml]


@string[value;params;name][result]
^if(!($value is junction)){
	^if(!($params is hash)){
		$params[^hash::create[$params]]
	}
	$method[$params.[$value.CLASS_NAME]]
	^if($method is junction){
		^xml:_exclude_endless_recursion[$value;$params;$name]{
			^method[$value;$params;$name]
		}
	}($value is string || $value is double || $value is integer){
#		$s[^value.match[</?[a-zA-Z][^^>]*>;g;]]
#		$s[^s.left(140)]
		^xml:tag[$name;;$value]
	}($value is bool){
		^xml:tag[$name;;^if($value){true}{false}]
	}($value is date){
		^xml:_date[$value;$params;$name]
	}($value is file){
		^xml:_file[$value;$params;$name]
	}($value is table){
		^xml:_table[$value;$params;$name]
	}($value is xdoc){
		^tag[$name;;^value.string[$.omit-xml-declaration[yes]]]
	}($value is xnode){
		^xml:_xnode[$value;$params;$name]
	}($value is regex){
		^xml:tag[$name;$.pattern[$value.pattern]$.options[$value.options];]
	}{
		^xml:_exclude_endless_recursion[$value;$params;$name]{
			^if($value is hash){
				^xml:_hash[$value;$params;$name]
			}{
				$methods[^reflection:methods[$value.CLASS_NAME]]
				^if(def $methods.xml_string){
					$params.[$value.CLASS_NAME][$value.xml_string]
					^value.xml_string[$value;$params;$name]
				}{
					$method[^xml:_find_method_for_base[$value;$params]]
					^if($method is junction){
						^method[$value;$params;$name]
					}{
						^xml:_hash[^reflection:fields[$value];$params;$name]
					}
				}
			}
		}
	}
}


@_exclude_endless_recursion[value;params;name;then][result]
$uid[^reflection:uid[$value]]
^if(!($params._processed)){
	$params._processed[^hash::create[]]
}
^if(!^params._processed.contains[$uid]){
	$params._processed.$uid[$name]
	$then
	^params._processed.delete[$uid]
}{
	^xml:tag[$name;^#20like_ancestor_node="$params._processed.$uid";]
}


@_find_method_for_base[value;params]
$base[^reflection:base[$value]]
^if(def $base){
	$method[$params.[$base.CLASS_NAME]]
	^if($method is junction){
		$params.[$value.CLASS_NAME][$method]
		$result[$method]
	}{
		$result[^xml:_find_method_for_base[$base;$params]]
	}
}{
	$result[]
}


@_file[value;params;name][result]
^self.tag[$name;
	$.ext[^value.name.match[^^.*?(?:\.([^^.]+))?^$;]{^match.1.lower[]}]
	$.stderr[$value.stderr]
	$.status[$value.status]
	$.mode[$value.mode]
;
	^xml:tag[name;;$value.name]
	^xml:file_size[$value.size]
	^xml:_date[$value.cdate;;created]
	^xml:_date[$value.mdate;;modified]
#	^xml:_date[$value.adate;;accessed]
	^if($params.include_file_content){
		^xml:tag[content;;^if($value.mode eq binary){^value.base64[]}{$value.text}]
	}
]


@file_size[size][result]
^if($size){
	^if($size > 1073741824){
		$estimate($size / 1073741824)
		$unit[GB]
	}($size > 1048576){
		$estimate($size / 1048576)
		$unit[MB]
	}($size > 1024){
		$estimate($size / 1024)
		$unit[KB]
	}{
		$estimate($size)
		$unit[B]
	}
	^xml:tag[size;^#20estimate="^math:round($estimate)^#20$unit";$size^#20Bytes]
}


@_date[value;params;name][result]
^if(!($value is date)){
	$value_string[$value]
	^if(def $value){
		^try{
			$value[^date::create[$value]]
		}{
			$exception.handled(true)
			$value[]
		}
	}
}{
	$value_string[^value.sql-string[]]
}
^if($value is date){
	^xml:tag[$name;
		$value_string_length(4)
		$.year[$value.year]

		^if($params.date_type ne dateyear){
			^value_string_length.inc(3)
			$.month[^value.month.format[%02d]]

			^if($params.date_type ne datemonth){
				^value_string_length.inc(3)
				$.day[^value.day.format[%02d]]
				$.weekday[^if(!$value.weekday){7}{$value.weekday}]

				^if($params.date_type ne date){
					^value_string_length.inc(9)
					$.time[^value.hour.format[%02d]:^value.minute.format[%02d]]
					$.gmt[^value.gmt-string[]]
				}
			}
		}
		$delta($value - $xml:now)
		^if($delta){
			$estimate(^math:abs($delta))
			^if($estimate > 364){
				$estimate($estimate / 365)
				$unit[year]
			}($estimate > 30){
				$estimate($estimate / 30)
				$unit[month]
			}($estimate > 6){
				$estimate($estimate / 7)
				$unit[week]
			}($estimate < 1 / 24){
				$estimate(24 * 60 * $estimate)
				$unit[minute]
			}($estimate < 1){
				$estimate(24 * $estimate)
				$unit[hour]
			}{
				$unit[day]
			}
			$.estimate[^if(^math:sign($delta) < 0){-}^math:round($estimate)^#20$unit]
		}
	;^value_string.left($value_string_length)]
}


##@_hash[value;params;name][result]
##^value.foreach[k;v]{
##	^if(def $v && ^k.pos[@] == 0){
##		$attrs[$attrs ^k.mid(1)="^taint[xml][$v]"]
##	}{
##		$inner[$inner^xml:string[$v;$params;$k]]
##	}
##}
##^xml:tag[$name;$attrs;$inner]


@_hash[value;params;name][result]
^value.foreach[k;v]{
	^if($v is bool){
		$v[^if($v){true}{false}]
	}
	^if(
		def $k && def $v && (
			$v is string
			|| $v is double
		)
		&& (^k.pos[@] == 0 || $params.simple_attrs)
	){
		$attrs[$attrs ^if(^k.match[^^\d]){a}^k.match[^^@;;]="^taint[xml][$v]"]
	}{
		$inner[$inner^xml:string[$v;$params;$k]]
	}
}
^xml:tag[$name;$attrs;$inner]


@_table[value;params;name][result]
$columns[^value.columns[]]
^value.menu{
	$inner[$inner^tag[item;;^columns.menu{^tag[$columns.column;;$value.[$columns.column]]}]]
}
^tag[$name;;$inner]


@_xnode[value;params;name]
$result[^switch[$value.nodeType]{
	^case[1]{^tag[$value.nodeName;^xml:string[$value.attributes;$params];^xml:string[$value.childNodes;$params]]}
	^case[2]{ $value.nodeName="$value.nodeValue"}
	^case[3]{$value.nodeValue}
}]


@tag[name;attrs;result]
^if($attrs is hash){
	$attrs[^attrs.foreach[k;v]{^if(def $v){ $k="^taint[xml][$v]"}}]
}
^if(def $name && (def $result || def $attrs)){
	^if(!^name.match[$xml:ncname_pattern]){
		$name[item]
	}
	$result[<${name}$attrs^if(def $result){>$result</$name}{/}>]
}


@head[params]
<?xml version="1.0"^if(def $params.encoding){ encoding="$params.encoding"}?>
<!DOCTYPE^#20^if($params.doctype eq html){html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"^#20}{^if(def $params.doctype){$params.doctype}{document} SYSTEM "^if(def $params.entities){$params.entities}{http://localhost/entities.xml}"}>

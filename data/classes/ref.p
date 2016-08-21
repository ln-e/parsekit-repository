# Copyright Art. Lebedev | http://www.artlebedev.ru/
# Author: Vladimir Tokmakov | vlalek
# Updated: 2015-06-26


@CLASS
ref

@OPTIONS
locals


@auto[]
$self._processed[^hash::create[]]


@copy[from;to;params]
^if(def $from && (def $to || $to is hash)){
	^if($params is hash){
		^if($params.clone){
			$from[^self._clone[$from]]
		}
		^if($params.passive){
			^if($params.recursive){
				$t[^self._copy_passive_recursive[$from;$to]]
				$copied(true)
			}{
				$t[^self._copy_passive[$from;$to]]
				$copied(true)
			}
		}($params.recursive){
			$t[^self._copy_recursive[$from;$to]]
			$copied(true)
		}
	}
	^if(!$copied){
		^reflection:copy[$from;$to]
	}
}
$result[]


@_clone[o]
$result[^hash::create[]]
^reflection:copy[$o;$result]
$uid[^reflection:uid[$o]]
$self._processed.$uid[]
$keys[^result._keys[]]
^keys.menu{
	$k[$keys.key]
	$v[$result.$k]
	^if(
		$v is string
		|| $v is double
		|| $v is void
		|| $v is bool
		|| $v is table
		|| $v is date
		|| $v is junction
	){}{
		^if(!^self._processed.contains[^reflection:uid[$o.$k]]){
			$result.$k[^self._clone[$v]]
		}
	}
}
^self._processed.delete[$uid]


@json_junction[a;b;c]
$result[null]


@_copy_recursive[from;to]
$p[^self._copy_init[$from;$to]]
^p.from.foreach[k;v]{
	^if(!^p.to.contains[$k] || !^self._copy_recursive[$from.$k;$to.$k]){
		$to.$k[$from.$k]
	}
}
$result(^p.from._count[])


@_copy_passive_recursive[from;to]
$p[^self._copy_init[$from;$to]]
^p.from.foreach[k;v]{
	^if(^p.to.contains[$k]){
		^if(def $v && def $to.$k){
			^self._copy_passive_recursive[$from.$k;$to.$k]
		}
	}{
		$to.$k[$from.$k]
	}
}
$result[]


@_copy_passive[from;to]
$p[^self._copy_init[$from;$to]]
^p.from.foreach[k;v]{
	^if(!^p.to.contains[$k]){
		$to.$k[$v]
	}
}
$result[]


@_copy_init[from;to]
$result[
	$.from[
		^if($from is hash){
			$from
		}{
			^reflection:fields[$from]
		}
	]
	$.to[
		^if($to is hash){
			$to
		}{
			^reflection:fields[$to]
		}
	]
]


@find_method[prefix;value;default;context]
^if(!$context){
	$context[$caller.self]
}
^if($context.[${prefix}$value] is junction){
	$result[$context.[${prefix}$value]]
}{
	$result[$context.[${prefix}$default]]
}


@class_path[class]
$result[^hash::create[]]
^if(!($class is string)){
	$base[^reflection:base[$class]]
	^if(def $base){
		$result[^self.class_path[$base]]
	}
	$class[^reflection:class_name[$class]]
}
$methods[^reflection:methods[$class]]
$methods[^methods._keys[]]
^methods.menu{
	$method_info[^reflection:method_info[$class;$methods.key]]
	^if(def $method_info.file && !def $method_info.inherited){
		$result.[^method_info.file.match[^^$request:document-root^(.*)/.*^$;]{$match.1}][]
		^break[]
	}
}


@object_json_string[key;value;params]
^if($value.json_string is junction){
	$result[^value.json_string[$key;$value;$params]]
}{
	$result[^self.hash_json_string[$key;^hash::create[$value];$params]]
}


@hash_json_string[key;value;params][locals]
$indent[$params.indent]

^if($params.indent is string){
	$indent1[$params.indent]
	$indent2[^params.indent.mid(1)]

	$params.indent[$indent1^indent1.left(1)]

	$return[^#0a]
}

^value.foreach[key;val]{
	^if(^key.pos[_] != 0 && def $val){
		$result[^if(def $result){$result,${return}$indent1}"$key":^json:string[$val;$params]]
	}
}
$result[^{^if(def $result){${return}${indent1}${result}${return}$indent2}^}]

$params.indent[$indent]



@removeDir[path;mask][result]

^if(-d $path){

	$list[^file:list[$path;$mask]]

	^if($list){
		^list.menu{
			^if(-f "${path}$list.name"){
				^file:delete[${path}$list.name]
			}(-d "${path}$list.name"){
                $test[]
                ^test.save[^self.normalize[${path}$list.name/.delete]] ^rem[hack to delete empty directories]
			    ^self.removeDir[${path}${list.name}/;$mask]
			}
		}
	}

}
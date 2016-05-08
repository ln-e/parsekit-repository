# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 08.05.16
# Time: 20:05
# To change this template use File | Settings | File Templates.

@CLASS
PackagesController

@OPTIONS
locals

@BASE
BaseController

@auto[]
    $self.security[^Security::create[]]
###

@create[]
###


@showAction[]
    ^if(!^self.security.isGranted[]){
        ^self.redirect[/login]
    }

    $doc[^xdoc::create[root]]
    $root[^doc.selectSingle[//root]]
    $packagesNode[^doc.createElement[packages]]
    $t[^root.appendChild[$packagesNode]]

    $user[^self.security.getUser[]]
    ^connect[$MAIN:SQL.connect-string]{
        $packages[^hash::sql{
            SELECT p.id, p.* FROM package as p
            LEFT JOIN package_user as pu ON p.id = pu.package_id
            WHERE pu.user_id = $user.id
        }]
    }


    ^packages.foreach[key;value]{
        $packageNode[^doc.createElement[package]]
        $t[^packagesNode.appendChild[$packageNode]]
        ^value.foreach[k;v]{
            $el[^doc.createElement[$k]]
            $el.nodeValue[$v]
            $t[^packageNode.appendChild[$el]]
        }
    }

    $transformedDoc[^doc.transform[../data/templates/packages/show.xsl]]

    ^if(def $transformedDoc){
        $result[^transformedDoc.string[
            $.method[html]
        ]]
    }{
        $result[]
    }
###


@addAction[]
    ^if(!^self.security.isGranted[]){
        ^self.redirect[/login]
    }{

        $data[{"name": "web","active": true,"events": ["create","delete","push","release"],"config": {"url": "http://parsekit.ru/hook","content_type": "json"}}]
        $name[^taint[as-is][$form:fields.package]]
        $parsekit[^self.getParkitFile[$name;master]]


        $user[^self.security.getUser[]]

        $file[^curl:load[
            $.url[https://api.github.com/repos/$name/hooks]
            $.useragent[parsekit]
            $.timeout(10)
            $.ssl_verifypeer(0)
            $.httpheader[
                $.Authorization[token $user.github_token]
                $.accept[application/json]
            ]
            $.post(1)
            $.postfields[$data]
        ]]

        $hookData[^json:parse[^taint[as-is][$file.text]]]
        ^if(!def $hookData.id){
            ^throw[CouldNotCreateHookException;;Hook creation failed: $file.text]
        }


        $readmeFile[^self.load[https://raw.githubusercontent.com/$name/master/README.md]]

        ^connect[$MAIN:SQL.connect-string]{
            $packageName[^if(!def $parsekit.name || ^parsekit.name.trim[] eq ''){$name}{$parsekit.name}]
            $r[^void:sql{
                INSERT INTO package(hook_id,name,target_dir,type,description,keywords,readme)
                VALUES(
                    $hookData.id,
                    '$packageName',
                    '$packageName',
                    '$parsekit.type',
                    '$parsekit.description',
                    '^if($parsekit.keywords is hash){^parsekit.keywords.foreach[i;keyword]{$keyword}[, ]}{ }',
                    '$readmeFile.text'
                )
            }]

            $packageId[^int:sql{SELECT last_insert_id()}]

            $r[^void:sql{
                INSERT INTO package_user(user_id,package_id)
                VALUES($user.id, $packageId)
            }]
        }

        $ping[^curl:load[
            $.url[^taint[as-is][$hookData.ping_url]]
            $.useragent[parsekit]
            $.timeout(10)
            $.ssl_verifypeer(0)
            $.httpheader[
                $.Authorization[token $user.github_token]
                $.accept[application/json]
            ]
            $.post(1)
        ]]

        ^self.redirect[/package]
    }
###

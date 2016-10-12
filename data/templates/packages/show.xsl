<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />

    <xsl:template name="page_title">
        <h1><xsl:value-of select="package/name"/></h1>
    </xsl:template>

    <xsl:template name="body_inner">
        <div>
            <table class="table">
                <body>
                    <tr>
                        <th>Name</th>
                        <td><xsl:value-of select="package/name" /></td>
                    </tr>
                    <tr>
                        <th>Type</th>
                        <td><xsl:value-of select="package/type" /></td>
                    </tr>
                    <tr>
                        <th>Description</th>
                        <td><xsl:value-of select="package/descirption" /></td>
                    </tr>
                    <tr>
                        <th>Keywords</th>
                        <td><xsl:value-of select="package/keywords" /></td>
                    </tr>
                    <tr>
                        <th>Installs</th>
                        <td><xsl:value-of select="package/installs" /></td>
                    </tr>
                    <tr>
                        <th>Created at</th>
                        <td><xsl:value-of select="package/created_at" /></td>
                    </tr>
                    <tr>
                        <th>Versions</th>
                        <td>
                            <ul>
                                <xsl:apply-templates select="package/versions/item" mode="versions" />
                            </ul>
                        </td>
                    </tr>
                </body>
            </table>

            <a href="/">Back to main page</a>

            <br/><br/>

            <xsl:if test="package/deleteUrl">
                <div class="well">
                    <a href="{package/deleteUrl}" class="btn btn-danger">Delete package</a>
                </div>
            </xsl:if>
        </div>
    </xsl:template>


    <xsl:template match="item" mode="versions">
        <li>
            <xsl:value-of select="version"/> (<xsl:value-of select="source_reference"/>)
        </li>
    </xsl:template>


</xsl:stylesheet>

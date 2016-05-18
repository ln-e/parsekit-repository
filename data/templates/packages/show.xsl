<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:template name="page_title">
        <h1>
          <xsl:value-of select="package/name"/></h1>
    </xsl:template>

    <xsl:template name="body_inner">
        <div class="uk-grid" data-uk-grid-margin="">
            <div class="uk-width-medium-1-1 uk-row-first">
                <table class="uk-table">
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
                            <th>Created at</th>
                            <td><xsl:value-of select="package/created_at" /></td>
                        </tr>
                        <tr>
                            <th>Versions</th>
                            <td>
                                <ul>
                                    <xsl:apply-templates select="package/versions/version" mode="versions" />
                                </ul>
                            </td>
                        </tr>
                    </body>
                </table>

                <a href="/">Back to main page</a>
            </div>
        </div>
    </xsl:template>


    <xsl:template match="version" mode="versions">
        <li>
            <xsl:value-of select="."/>
        </li>
    </xsl:template>


</xsl:stylesheet>

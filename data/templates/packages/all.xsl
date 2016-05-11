<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />


    <xsl:template name="page_title">Last 10 added packages</xsl:template>


    <xsl:template name="body_inner">
        <div class="uk-grid" data-uk-grid-margin="">
            <div class="uk-width-medium-1-1 uk-row-first">
                <table class="uk-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Description</th>
                            <th>Keywords</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="packages/package" mode="packages_list" />
                    </tbody>
                </table>
            </div>
        </div>
    </xsl:template>


    <xsl:template match="package" mode="packages_list">
        <tr>
            <td>
                <xsl:value-of select="name"/>
            </td>
            <td>
                <xsl:value-of select="type"/>
            </td>
            <td>
                <xsl:value-of select="description"/>
            </td>
            <td>
                <xsl:value-of select="keywords"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
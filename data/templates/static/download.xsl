<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:import href="../_base.xsl" />

    <xsl:output indent="no" omit-xml-declaration="yes" method="html" />


    <xsl:template name="page_title">Parsekit Installation</xsl:template>


    <xsl:template name="body_inner">
        <div>
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Version</th>
                        <th>Build Date</th>
                        <th>Link</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="dists/item" mode="dists_list" >
                      <xsl:sort select="position()" data-type="number" order="descending"/>
                    </xsl:apply-templates>
                    <xsl:if test="count(dists/item) = 0">
                        <td colspan="3">No downloads available</td>
                    </xsl:if>
                </tbody>
            </table>
        </div>
    </xsl:template>


    <xsl:template match="item" mode="dists_list">
        <tr>
            <td>
                <xsl:value-of select="version"/>
            </td>
            <td>
                <xsl:value-of select="date"/>
            </td>
            <td>
                <a href="{file}" target="_blank">download</a>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>

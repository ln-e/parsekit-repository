<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="../../_base.xsl" />


  <xsl:template name="page_title">Users</xsl:template>

  <xsl:template name="body_inner">
      <div class="uk-grid" data-uk-grid-margin="">
          <div class="uk-width-medium-1-1 uk-row-first">
              <table class="uk-table">
                  <thead>
                      <tr>
                          <th>id</th>
                          <th>email</th>
                      </tr>
                  </thead>
                  <tbody>
                      <xsl:apply-templates select="users/user" mode="users_list" />
                  </tbody>
              </table>
          </div>
      </div>
  </xsl:template>


  <xsl:template match="user" mode="users_list">
      <tr>
          <td>
              <a href="user/{id}">
                  <xsl:value-of select="id"/>
              </a>
          </td>
          <td>
              <xsl:value-of select="email"/>
          </td>
      </tr>
  </xsl:template>


</xsl:stylesheet>

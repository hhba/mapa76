<style>
  a{
      text-decoration:none;
  }
</style>
<script src='/javascripts/jquery.tinysort.min.js'></script>
<h1><%=@doc.title%></h1>
<div style='position:absolute; right:0px;'>
<button id="sort_by_name">Ordenar por nombre</button>
<button id="sort_by_mentions">Ordenar por menciones</button>
</div>
<ol class='list_mode' id='persons'>
    <%@people.each{|person|%>
      <li data-mentions='<%=person.mentions_in(@doc)%>'><span class='name'><%=link_to(person.name.titleize,url_for(:doc_admin_person, :id => person.id, :doc_id => @doc.id))%></span> (<%=person.mentions_in(@doc)%> menciones)  
    <%}%>
</ol>

<script>
    $("#sort_by_name").click(function(e){$("ol#persons>li").tsort()})
    $("#sort_by_mentions").click(function(e){$("ol#persons>li").tsort({attr:"data-mentions",order:"desc"})})
</script>

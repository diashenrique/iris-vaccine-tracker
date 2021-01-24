Class diashenrique.REST.Dispatch Extends diashenrique.REST.Base
{

Parameter Version = "1.0.0";

Parameter Global = "^dc.Sample.PersonD";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Get all records of Person class -->
<Route Url="/persons/all" Method="GET" Call="GetAllPersons"/>
<!-- Get a record via SQL API-->
<Route Url="/sql/list" Method="GET" Call="GetVaccinationDetails"/>
<!-- Get a record via KeyValue API-->
<Route Url="/multi/keyval/:id" Method="GET" Call="GetPersonKeyValue"/>

</Routes>
}

/// PersonsREST general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET info = {
    "version": (version)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

/// Generate records of Sample.Person
ClassMethod GenerateRecords(amount As %Integer) As %Status
{
    set sc = $$$OK
    do ##class(dc.Sample.Person).AddTestData(amount)
    return sc
}

/// Retreive all the records of dc.Sample.Person in JSON
ClassMethod GetAllPersons() As %Status
{

    #dim tSC As %Status = $$$OK

    Set rset = ##class(dc.Sample.Person).ExtentFunc()

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Write "["
    if rset.%Next() {
        Set person = ##class(dc.Sample.Person).%OpenId(rset.ID)    
        Do person.%JSONExport()
    }
    While rset.%Next() {   
        Write ","
        Set person = ##class(dc.Sample.Person).%OpenId(rset.ID)    
        Do person.%JSONExport()
    }
    Write "]"
    Quit tSC
}

/// Return one record of dc.Sample.Person in JSON via ObjectScript 
ClassMethod GetPersonObject(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #; Set the response header to plain text
    Set %response.ContentType = ..#CONTENTTYPEJSON
    Set person = ##class(dc.Sample.Person).%OpenId(id)
    If '$IsObject(person) Quit ..Http404()
    Do person.%JSONExport()
    Quit tSC
}

/// return a list with all vaccination for each Country
ClassMethod GetVaccinationDetails() As %Status
{
    set sc = $$$OK
    set sql="SELECT CountryId->Name, DateReport, Vaccine, TotalVaccinations FROM diashenrique_data.Vaccinations"
    do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql)
    return sc
}

/// return a record of dc.Sample.Person in JSON via Key Value
ClassMethod GetPersonKeyValue(id As %Integer) As %Status
{
    set sc = $$$OK
    set record=$get(@..#Global@(id))
    If record="" Quit ..Http404()
    set json={}
    set json.Name=$lg(record,2)
    set json.Title=$lg(record,3)
    set json.Company=$lg(record,4)
    write json.%ToJSON()
    return sc
}

ClassMethod SwaggerSpec() As %Status
{
  Set tSC = ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = "/crud"
  Set swagger.info.title = "InterSystems IRIS REST MULTI-MODEL CRUD demo"
  Set swagger.info.version = "0.1"
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

}

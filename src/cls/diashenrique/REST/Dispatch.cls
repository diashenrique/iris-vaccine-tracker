Class diashenrique.REST.Dispatch Extends diashenrique.REST.Base
{

Parameter Version = "1.0.0";

Parameter Global = "^dc.Sample.PersonD";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Get a record via SQL API-->
<Route Url="/sql/list" Method="GET" Call="GetCountryList"/>
<Route Url="/sql/map" Method="GET" Call="GetMapList"/>
<!-- Get a record via Global-->
<Route Url="/global/header" Method="GET" Call="GetGlobalHeader"/>
<Route Url="/global/topvacbycountry" Method="GET" Call="GetGlobalVacByCountry"/>
<Route Url="/global/topvacbarchart" Method="GET" Call="GetBarchartVacByCountry"/>
<Route Url="/global/vaccineperc" Method="GET" Call="GetVaccineQty"/>

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

/// return a list with all vaccination for each Country
ClassMethod GetVaccinationDetails() As %Status
{
    set sc = $$$OK
    set sql="SELECT CountryId->Name, DateReport, Vaccine, TotalVaccinations FROM diashenrique_data.Vaccinations"
    do ##class(%ZEN.Auxiliary.jsonSQLProvider).%WriteJSONFromSQL(,sql)
    return sc
}

/// Return a top 15 most vaccinatd
ClassMethod GetCountryList() As %Status
{
	Set %response.ContentType = "application/json"

	Set tSC = $System.Status.OK()
	Set arrayList = []
    
    Set arrayAll = []

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT CountryId->Name as Country, DateReport, Vaccine, TotalVaccinations FROM diashenrique_data.Vaccinations"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
                Set arrayLine = []
	        	do arrayLine.%Push(result.Country)
	        	do arrayLine.%Push($zdate(result.DateReport,3))
	        	do arrayLine.%Push(result.Vaccine)
	        	do arrayLine.%Push(result.TotalVaccinations)
                do arrayList.%Push(arrayLine)
            }
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    do arrayList.%ToJSON()

    quit tSC
}

/// GetGlobalHeader return the values of Total of Vaccines, Countries and Vaccinations
ClassMethod GetGlobalHeader() As %Status
{
    Set sc = $$$OK
    
    set totalVaccination = $get(^VaccineSum("Total"),0)
    set totalVaccine = $get(^VaccineSum("VacType"),0)
    set totalCountries = $get(^VaccineSum("Country"),0)

    set json={}
    set json.totalVaccination=totalVaccination
    set json.totalVaccine=totalVaccine
    set json.totalCountries=totalCountries
    write json.%ToJSON()
    Return sc
}

/// GetGlobalVacByCountry return the top 20 most vaccinated countries so far
ClassMethod GetGlobalVacByCountry() As %Status
{
    Set sc = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON

    set arrAll=[]
    set dynamicAll={}
    set dynamicCountry={}

    set listCountries = ^TopCountries

    set count=0
    set country = ""
    for {

        set country=$order(^CountryByDate(country))
        continue:('$listfind(listCountries,country))
        quit:(country="")

        set count=$increment(count)

        set arrCountry=[]
        set arrValues = []

        set date = ""
        for {
            set date = $order(^CountryByDate(country,date))
            quit:date=""
            
            set json = {}
            set objDate = $get(^CountryByDate(country,date))
            
            do json.%Set("x",$zdate(date,1))
            do json.%Set("y",objDate)
            do arrValues.%Push(json)
            do arrCountry.%Push(arrValues)
        }

        set jsoncountry = {}
        do jsoncountry.%Set("name",country)
        do jsoncountry.%Set("data",arrValues)
        do arrAll.%Push(jsoncountry)

        quit:(count=11)
    }

    do arrAll.%ToJSON()
    Return sc
}

/// GetBarchartVacByCountry return data for bar chart
ClassMethod GetBarchartVacByCountry() As %Status
{
    Set sc = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON

    set arrayValues = []
    set arrayCountry = []
    set arrayAll = []
    set dynamicBar = {}

    set (listValue,listName)=""

    set value = ""
    for {
        set value = $order(^BarTopCountries(value),-1)
        quit:value=""

        set countryName = $get(^BarTopCountries(value))

        do arrayValues.%Push($number(value))
        do arrayCountry.%Push(countryName)        
    }

    do arrayAll.%Push(arrayValues)
    do arrayAll.%Push(arrayCountry)
   
    do arrayAll.%ToJSON()

    Return sc
}

/// GetVaccinaQty
ClassMethod GetVaccineQty() As %Status
{
    Set sc = $$$OK
    Set %response.ContentType = ..#CONTENTTYPEJSON
    
    kill ^tmpVaccine 

    set qty=0
    set vaccineName=""
    for {
        set vaccineName=$order(^VaccineTypeByCountry(vaccineName))
        quit:vaccineName=""

        set countryName = ""
        set qtyVaccineCountry=0
        for {
            set countryName=$order(^VaccineTypeByCountry(vaccineName,countryName))
            quit:countryName=""

            set qtyVaccineCountry = $get(^VaccineTypeByCountry(vaccineName,countryName))

            set ^tmpVaccine(vaccineName)=$get(^tmpVaccine(vaccineName),0)+qtyVaccineCountry
        }
    }

    set arrayQty = []
    set arrayVaccine = []
    set arrayAll = []

    set totalCountry = $get(^VaccineSum("Country"),0)

    set (listValue,listName)=""

    set vaccine = ""
    for {
        set vaccine = $order(^tmpVaccine(vaccine))
        quit:vaccine=""

        set qtyVaccine = $get(^tmpVaccine(vaccine))

        set percVaccine = (qtyVaccine * 100) / totalCountry
        set percVaccine = $normalize(percVaccine,2)

        do arrayQty.%Push($number(percVaccine))
        do arrayVaccine.%Push(vaccine)        
    }

    do arrayAll.%Push(arrayQty)
    do arrayAll.%Push(arrayVaccine)
   
    do arrayAll.%ToJSON()

    Return sc
}

/// GetMapList - Give the information to fill and render the heat map
ClassMethod GetMapList() As %Status
{
    Set %response.ContentType = "application/json"

	Set tSC = $System.Status.OK()
	Set arrayMap = []
    Set dynamicMap = {}

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT CountryId->Alpha2 as Alpha2, CountryId->Name as Country, MAX(TotalVaccinations) As TotalVaccinations FROM diashenrique_data.Vaccinations Group By CountryId Order By TotalVaccinations DESC"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
                Set json = {}
                do json.%Set("id",result.Alpha2)
                do json.%Set("name",result.Country)
                do json.%Set("value",$number(result.TotalVaccinations))
	        	do arrayMap.%Push(json)
            }
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    ;do dynamicMap.%Set(arrayMap)
    do arrayMap.%ToJSON()

    quit tSC
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

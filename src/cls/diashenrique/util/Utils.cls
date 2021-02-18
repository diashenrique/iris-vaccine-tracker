Include %systemInclude

/// Class for general utilities 
Class diashenrique.util.Utils
{

/// Description
Parameter DATAPATH = "csp/vaccine/data";

/// Load Latitude Longitude based on ISOCode
/// do ##class(diashenrique.util.Utils).loadLatitudeLongitude()
ClassMethod loadLatitudeLongitude() As %Status
{
    Set sc = $$$OK
    Set tDataPath=##class(%File).NormalizeDirectory(..#DATAPATH, $System.Util.InstallDirectory())
    set file = ##class(%File).%New(tDataPath_"/countries_codes_and_coordinates_full_pop.csv")
    set sc = file.Open("R")
    if $$$ISERR(sc) quit

    set count = 0
    set (tAlpha2, tAlpha3, tNumeric, tLatitude, tLongitude, tCountryName, tPopulation) = ""

    while 'file.AtEnd {
        set count = $INCREMENT(count)
        set line = file.ReadLine()
        quit:(line="")
        continue:(count=1)
        
        set tAlpha2 = $piece(line,";",1)
        set tAlpha3 = $piece(line,";",2)
        set tNumeric = $piece(line,";",3)
        set tLatitude = $piece(line,";",4)
        set tLongitude = $piece(line,";",5)
        set tCountryName = $piece(line,";",6)
        set tPopulation = $piece(line,";",7)

        set ^LatitudeLongitude(tAlpha3)=tLatitude_"^"_tLongitude_"^"_tCountryName_"^"_tAlpha2_"^"_tNumeric_"^"_tPopulation
    }
    do file.Close()
    Return sc
}

/// Read and Populate Country class
/// do ##class(diashenrique.util.Utils).readAndInsertCountry()
ClassMethod readAndInsertCountry() As %Status
{
    Set sc = $$$OK

    set tISOCode=""
    for  {
        set tISOCode=$order(^LatitudeLongitude(tISOCode)) 
        quit:tISOCode=""

        set (tAlpha2, tNumeric, tLatitude, tLongitude, tCountryName) = ""

        set oCountryDetail = $get(^LatitudeLongitude(tISOCode))
        
        set tCountryName = $piece(oCountryDetail,"^",3)
        set tLatitude = $piece(oCountryDetail,"^",1)
        set tLongitude = $piece(oCountryDetail,"^",2)
        set tAlpha2 = $piece(oCountryDetail,"^",4)
        set tNumeric = $piece(oCountryDetail,"^",5)
        set tPopulation = $piece(oCountryDetail,"^",6)

        set objCountry = ##class(diashenrique.data.Country).%New()
        set objCountry.Name = tCountryName
        set objCountry.Alpha2 = tAlpha2
        set objCountry.Alpha3 = tISOCode
        set objCountry.ISONumeric = tNumeric
        set objCountry.Latitude = tLatitude
        set objCountry.Longitude = tLongitude
        set objCountry.Population = tPopulation
        set sc = objCountry.%Save()
        quit:$$$ISERR(sc)
    }

    Return sc
}

/// Get CSV file name inside directory "/opt/irisapp/dataImport/country_data/"
/// do ##class(diashenrique.util.Utils).readFiles()
ClassMethod readFiles() As %Status
{
    Set sc = $$$OK
    Set tFilePath = ""
    Set tDataPath=##class(%File).NormalizeDirectory(..#DATAPATH, $System.Util.InstallDirectory())
    Set tRS = ##class(%ResultSet).%New("%Library.File:FileSet")
    Set tSC = tRS.Execute(tDataPath_"/country_data/","*.csv",,0)                 

    set count = 0
    While (tRS.Next()) {
        set count = $INCREMENT(count)
        Set tFile = ##Class(%FileCharacterStream).%New() 
        set tFilePath = tRS.Get("Name")
        do ..readDataCountry(tFilePath)
        ;quit:(count=3)
    }

    Return sc
}

/// Read vaccination data from each Country inside diretory
/// do ##class(diashenrique.util.Utils).readDataCountry()
ClassMethod readDataCountry(pFilePath As %String) As %Status
{
    set count = 0
    set (tCountryIndice,tFileCountry,tCountryId,tVaccinationDate,tVaccineName,tSourceURL,tTotalVaccinations,tPeopleVaccinated,tFullyVaccinated) = ""

    set sc = $$$OK
    set file = ##class(%File).%New(pFilePath)
    set sc = file.Open("R")
    if $$$ISERR(sc) quit

    set countryNameFile = $piece($piece(pFilePath,"/",*),".",1)
    ;write "countryNameFile:"_countryNameFile,! 

    // Get CountryID on Index Global ^CountryI
    set tCountryIndice = " "_countryNameFile
    ;write "tCountryIndice:"_tCountryIndice,!

    if '$data(^CountryI("IndexCountryName",$ZCONVERT(tCountryIndice,"U"))) {
        quit
    }
    set tCountryId = $order(^CountryI("IndexCountryName",$ZCONVERT(tCountryIndice,"U"),""))
    ;write "tCountryId:"_tCountryId,!

    set tCountryId = ##class(diashenrique.data.Country).%OpenId(tCountryId)
    ;write "objId:"_tCountryId.Name,!

    while 'file.AtEnd {
        set count = $INCREMENT(count)
        set line = file.ReadLine()
        quit:(line="")

        ;skip header file
        continue:(count=1)

        set tVaccinationDate = $zdateh($piece(line,",",2),3)

        if $find($piece(line,",",3),"""") {
            set tVaccineName = $piece(line,"""",2)
        } else {
            set tVaccineName = $piece(line,",",3)
        }

        set tTotalVaccinations = $piece(line,",",*-2)
        if (tTotalVaccinations="") set tTotalVaccinations = 0

        set tPeopleVaccinated = $piece(line,",",*-1)
        if (tPeopleVaccinated="") set tPeopleVaccinated = 0

        set tFullyVaccinated = $piece(line,",",*)
        if (tFullyVaccinated="") set tFullyVaccinated = 0

        set objVaccination = ##class(diashenrique.data.Vaccinations).%New()
        set objVaccination.CountryId = tCountryId
        set objVaccination.DateReport = tVaccinationDate
        set objVaccination.Vaccine = tVaccineName
        set objVaccination.TotalVaccinations = tTotalVaccinations
        set objVaccination.PeopleVaccinated = tPeopleVaccinated
        set objVaccination.FullyVaccinated = tFullyVaccinated
        set sc = objVaccination.%Save()
        
        if $$$ISERR(sc) $$$ThrowOnError(sc)
    }
    do file.Close()
    Return sc
}

/// Creating globals for summary data and help data charts
/// do ##class(diashenrique.util.Utils).createGlobalSummary()
ClassMethod createGlobalSummary() As %Status
{
    Set tSC = $System.Status.OK()

    kill ^VaccineTypeByCountry
    kill ^CountryByDate
    kill ^PercentByDate

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT CountryId->Name as Country, DateReport, Vaccine, TotalVaccinations, CountryId->Population as Population FROM diashenrique_data.Vaccinations ORDER BY CountryId->Name ASC"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
                set tCountry = result.Country
                set tDate = result.DateReport
                set tVaccine = result.Vaccine
                set tTotal = result.TotalVaccinations
                set tPopulation = result.Population

	        	set ^CountryByDate(tCountry,tDate) = tTotal

                set tPercVaccination = $number(((tTotal * 100) / tPopulation),3)
                set ^PercentByDate(tCountry,tDate) = tPercVaccination
                
                set i=0
                for i=1:1:$length(tVaccine,", ") {
                    set qty = $normalize(1/$length(tVaccine,", "),3)
                    set tVac = $piece(tVaccine,", ",i)
                    set ^VaccineTypeByCountry(tVac,tCountry)=qty
                }
            }        
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    Quit tSC
}

/// Creating globals for summary data and help data charts
/// do ##class(diashenrique.util.Utils).createSummaryHeader()
ClassMethod createSummaryHeader() As %Status
{
    Set tSC = $System.Status.OK()

    kill ^VaccineByCountry
    kill ^VaccineSum

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT CountryId->Name as Country, MAX(DateReport) as DateReport, MAX(TotalVaccinations) As TotalVaccinations FROM diashenrique_data.Vaccinations Group By CountryId Order By TotalVaccinations DESC"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set result = oRS.%Execute()

        set ^VaccineSum("Total")=0
        set countryCount = 0

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
                set countryCount = $increment(countryCount)
                set tCountry = result.Country
                set tTotal = result.TotalVaccinations

	        	set ^VaccineByCountry(tCountry) = tTotal
                set ^VaccineSum("Total")=$get(^VaccineSum("Total"))+tTotal
                set ^VaccineSum("Country")=countryCount
            }            
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }

        set countVacType = 0
        set tVacType = ""
        for  {
            set tVacType = $order(^VaccineTypeByCountry(tVacType))
            quit:tVacType=""

            set countVacType = $increment(countVacType)
            set ^VaccineSum("VacType")=countVacType
        }
    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    Quit tSC
}

/// Creating a global for top most vaccinated countries
/// do ##class(diashenrique.util.Utils).createTopList()
ClassMethod createTopList() As %Status
{
    Set tSC = $System.Status.OK()

    kill ^TopCountries
    kill ^BarTopCountries
    set list=""
    set listCountries=""

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT TOP 10 CountryId, CountryId->Name as Country, MAX(DateReport) as DateReport, MAX(TotalVaccinations) As TotalVaccinations FROM diashenrique_data.Vaccinations Group By CountryId Order By TotalVaccinations DESC"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
                set listCountries = listCountries_","_result.Country
                set ^BarTopCountries(result.TotalVaccinations)=result.Country
            }
            set list=$listfromstring(listCountries)
            set ^TopCountries=list
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    Quit tSC
}

/// Create a global with the countries with the highest percentage vaccination population
ClassMethod createPercentList() As %Status
{
    Set tSC = $System.Status.OK()

    kill ^HighPercCountries
    kill ^BarHighCountries

    set list=""
    set listCountries=""
    set percent = ""

    Try {

		Set oRS = ##class(%SQL.Statement).%New()

        Set sql = "SELECT TOP 10 CountryId, CountryId->Name as Country, MAX(DateReport) as DateReport, MAX(TotalVaccinations) As TotalVaccinations, "_
            "CountryId->Population as Population, (MAX(TotalVaccinations)*100/(CountryId->Population)) as PercentPopulation FROM diashenrique_data.Vaccinations "_
            "Group By CountryId Order By PercentPopulation DESC"

        Set tSC = oRS.%Prepare(sql)

        Quit:$System.Status.IsError(tSC)

        Set result = oRS.%Execute()

        If (result.%SQLCODE '< 0) {
	        While result.%Next() {
                set listCountries = listCountries_","_result.Country
                set percent = $number(result.PercentPopulation,3)
                set ^BarHighCountries(percent)=result.Country
            }
            set list=$listfromstring(listCountries)
            set ^HighPercCountries=list
        }
        Else {
            Throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
        }
    }
    Catch (oException) {
        Set tSC = oException.AsStatus()
    }

    Quit tSC
}

}

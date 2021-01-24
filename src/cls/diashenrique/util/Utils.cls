Include %systemInclude

/// Class for general utilities 
Class diashenrique.util.Utils
{

/// Load Latitude Longitude based on ISOCode
/// do ##class(diashenrique.util.Utils).loadLatitudeLongitude()
ClassMethod loadLatitudeLongitude() As %Status
{
    Set sc = $$$OK
    set file = ##class(%File).%New("/opt/irisapp/dataImport/countries_codes_and_coordinates_full.csv")
    set sc = file.Open("R")
    if $$$ISERR(sc) quit

    set count = 0
    set (tAlpha2, tAlpha3, tNumeric, tLatitude, tLongitude, tCountryName) = ""

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

        set ^LatitudeLongitude(tAlpha3)=tLatitude_"^"_tLongitude_"^"_tCountryName_"^"_tAlpha2_"^"_tNumeric
    }
    do file.Close()
    Return sc
}

/// Read and Populate Country class
/// do ##class(diashenrique.util.Utils).readAndInsertCountry()
ClassMethod readAndInsertCountry() As %Status
{
    Set sc = $$$OK
    set file = ##class(%File).%New("/opt/irisapp/dataImport/locations.csv")
    set sc = file.Open("R")
    if $$$ISERR(sc) quit

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

        set objCountry = ##class(diashenrique.data.Country).%New()
        set objCountry.Name = tCountryName
        set objCountry.Alpha2 = tAlpha2
        set objCountry.Alpha3 = tISOCode
        set objCountry.ISONumeric = tNumeric
        set objCountry.Latitude = tLatitude
        set objCountry.Longitude = tLongitude
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
    
    Set tRS = ##class(%ResultSet).%New("%Library.File:FileSet")
    Set tSC = tRS.Execute("/opt/irisapp/dataImport/country_data/","*.csv",,0)                 

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

    set countryNameFile = $piece($piece(pFilePath,"/",6),".",1)
    ;write "countryNameFile:"_countryNameFile,! 

    // Get CountryID on Index Global ^CountryI
    set tCountryIndice = " "_countryNameFile
    ;write "tCountryIndice:"_tCountryIndice,!
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

}

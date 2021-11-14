*** Settings ***    
Documentation
Library     RPA.Browser
Library     RPA.HTTP
Library     RPA.Tables
Library     RPA.Excel.Files
Library     Screenshot
Library     RPA.PDF
Library     RPA.Archive
Library     RPA.RobotLogListener


# +
*** Keywords ***
Opening the web Browser
        Open Available Browser      https://robotsparebinindustries.com/#/robot-order
        Click Button  //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
Download the Csv file
    Download      https://robotsparebinindustries.com/orders.csv      overwrite=True

Fill And Submit The Form For One Person
    [Arguments]    ${orders} 
    Wait Until Page Contains Element      id:head
    Select From List By Value    id:head    ${orders}[Head]
    Select Radio Button     body        id-body-${orders}[Body]
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${orders}[Legs]
    Input Text    id:address    ${orders}[Address]
    Wait Until Page Contains Element    id:preview
    Click Button   id:preview     
    Wait Until Page Contains Element    id:order
   Click Button   id:order
   Sleep  1s
   #Wait Until Keyword Succeeds   3x  0.5 sec  id:order
   Wait Until Page Contains Element    id:robot-preview-image
   Screenshot      id:robot-preview-image    ${CURDIR}${/}output${/}${orders}[Order number].png    
     #Wait Until Keyword Succeeds    3x    0.5 sec   id:receipt
    Screenshot      id:receipt    ${CURDIR}${/}output${/}receipt${/}${orders}[Order number].png
    receipt to pdf  ${orders}
    
     Wait Until Page Contains Element  //*[@id="order-another"]
    Click Button    //*[@id="order-another"]
     Wait Until Page Contains Element     //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
     Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]   

# -

*** Keywords ***
receipt to pdf
        [Arguments]    ${orders}
    Wait Until Element Is Visible    id:receipt
    ${ordersDt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${ordersDt}    ${CURDIR}${/}output${/}pdf${/}${orders}[Order number].pdf

***** Keywords ***
Merging pdf and png
        [Arguments]    ${orders}
  Add Watermark Image To Pdf        ${CURDIR}${/}output${/}${orders}[Order number].png   ${CURDIR}${/}output${/}pdf${/}${orders}[Order number].pdf   ${CURDIR}${/}output${/}pdf${/}${orders}[Order number].pdf

*** Keywords ***
Fill The Form Using The Data From The Excel File
    ${robo_order}=   Read table from CSV     orders.csv  header=True
    [Return]        ${orders}
       
   FOR    ${orders}    IN    @{robo_order}
     Wait Until Keyword Succeeds   5x  0.5 sec  Fill And Submit The Form For One Person    ${orders}
     Merging pdf and png  ${orders}
      
    
   END

# +
*** Keywords ***
 Receipt to Zip
  Archive Folder With Zip  ${CURDIR}${/}output${/}pdf  receipt.zip
  


# -

*** Tasks ***
final output
  Receipt to Zip

*** Keywords ***
 #Collecting the screenshot
     [Arguments]    ${orders}
     #Wait Until Page Contains Element    id:robot-preview-image
     Screenshot      id:robot-preview-image    ${CURDIR}${/}output${/}${orders}[Order number].png    
     #Wait Until Keyword Succeeds    3x    0.5 sec   id:receipt
    Screenshot      id:receipt    ${CURDIR}${/}output${/}receipt${/}${orders}[Order number].png


*** Tasks ***
web Browser Opening
    Opening the web Browser
    Download the Csv file
    Fill The Form Using The Data From The Excel File
    #Receipt to Zip




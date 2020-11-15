# PowerShell script show query result from PostgreSql DB 

# Set path to npgsql.dll
$myDllPath = "..."

# Set query to DB PostgreSql
$query = "select ..."

# Set query result column
$queryColumnName = "count"

# Set connection string to DB PostgreSql
$ConnString = "server=...;port=5432;user id=...;password=...;database=...;pooling=false"

# Start

# Create DB environment
Add-Type -Path $myDllPath
$Conn = New-Object Npgsql.NpgsqlConnection
$Conn.ConnectionString = $ConnString

#
while($true)
{ 
 # Open DB connection, execute query, close connection
 $Conn.Open()
 $Command = $Conn.CreateComand()
 $Command.CommandText = $query
 $adapter = New-Object -Typename Npgsql.NpgsqlDataAdapter $Command
 $dataset = New-Object -Typename System.Data.DataSet
 $adapter.Fill($dataset)
 $Conn.Close()

 # Clear screen
 # cls
 
 # Show query result
 ForEach($Row in $dataset.Tables[0].Rows)
 {
   Write-Host $Row.$queryColumnName
 }
 
 # Delay before repeat query
 sleep -seconds 5
}
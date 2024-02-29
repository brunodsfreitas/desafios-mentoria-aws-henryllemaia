<!DOCTYPE html>
<html>
<head>
    <title>Consulta PHP</title>
    <style>
        body {
            background: linear-gradient(45deg, #fff, #6b50f2, #fff);
            background-size: 400% 400%;
            animation: gradientBackground 10s ease infinite;
            color: #333;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        @keyframes gradientBackground {
            0% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
            100% {
                background-position: 0% 50%;
            }
        }

        .container {
            text-align: center;
        }
        .result {
            background-color: #f9f9f9;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>

<div class="container">
    <?php
    require_once 'config.php';

    $host = DB_HOST;
    $dbname = DB_NAME;
    $user = DB_USER;
    $password = DB_PASSWORD;
    $_command = COMMAND;

    // Connect to PostgreSQL
    $dsn = "pgsql:host=$host;dbname=$dbname;user=$user;password=$password";
    $start_time = microtime(true);
    try {
        $db = new PDO($dsn);
        echo "<div class='result'>Conectado ao banco:<br>$host</div>";

        $query = $db->query($_command);
        $result = $query->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($result)) {
            echo "<div class='result'><table>";
            // Output headers
            echo "<tr>";
            foreach ($result[0] as $key => $value) {
                echo "<th>$key</th>";
            }
            echo "</tr>";
            // Output data
            foreach ($result as $row) {
                echo "<tr>";
                foreach ($row as $value) {
                    echo "<td>$value</td>";
                }
                echo "</tr>";
            }
            echo "</table></div>";
        } else {
            echo "<div class='result'>No data found!</div>";
        }
    } catch (PDOException $e) {
        echo "<div class='result'>Falha na conexão com o banco: " . $e->getMessage() . "</div>";
    }

    // Calculate and output the time taken
    $end_time = microtime(true);
    $execution_time = ($end_time - $start_time);
    echo "<div class='result'>Query executada em " . $execution_time . " segundos.</div>";
    ?>
</div>

</body>
</html>

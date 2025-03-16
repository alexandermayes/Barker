-- Version : French ( by LenweSaralonde )
-- Enhanced by Claude

if (GetLocale() == "frFR") then
	BARKER_LOAD = "Barker VERSION chargé. Tapez /bkrhelp pour obtenir de l'aide ou /bkrui pour ouvrir l'interface."

	-- Basic messages
	BARKER_STATS = "\"MESSAGE\" est envoyé toutes les RATE secondes dans le canal /CHANNEL."
	BARKER_STATS_MULTI = "COUNT messages en rotation seront envoyés avec un intervalle de base de RATE secondes."

	BARKER_MESSAGE = "Le message est maintenant \"MESSAGE\"."
	BARKER_RATE = "Le message est envoyé toutes les RATE secondes."
	BARKER_RATE_VARIANCE = "La variance d'intervalle est maintenant de VARIANCE secondes."
	BARKER_CHANNEL = "Le message est envoyé dans le canal /CHANNEL."

	BARKER_ACTIVE = "Barker est activé."
	BARKER_INACTIVE = "Barker est désactivé."

	BARKER_ERR_CHAN = "Le canal /CHANNEL est invalide."
	BARKER_ERR_RATE = "Vous ne pouvez pas envoyer de messages à moins de RATE secondes d'intervalle."
	BARKER_ERR_NUMBER = "Veuillez saisir un nombre valide."
	BARKER_ERR_EMPTY_MESSAGE = "Le message ne peut pas être vide."
	BARKER_ERR_MESSAGE_MODE = "Les modes de messages valides sont : random, sequential"
	BARKER_ERR_HOURS = "Les heures doivent être comprises entre 0 et 24."
	BARKER_ERR_DAY = "Le jour doit être compris entre 1 et 7."

	-- Enhanced messages
	BARKER_MESSAGE_ADDED = "Message #INDEX ajouté à la rotation."
	BARKER_MESSAGE_REMOVED = "Message #INDEX supprimé de la rotation."
	BARKER_CURRENT_MESSAGES = "Messages actuels en rotation :"
	BARKER_MESSAGE_MODE = "Mode de rotation des messages défini sur : MODE"
	BARKER_INVALID_MESSAGE_INDEX = "Index de message invalide."

	BARKER_CHANNEL_ADDED = "Canal CHANNEL ajouté."
	BARKER_CHANNEL_REMOVED = "Canal CHANNEL supprimé."
	BARKER_CHANNEL_EXISTS = "Le canal CHANNEL existe déjà."
	BARKER_CHANNEL_TOGGLE = "Le canal CHANNEL est maintenant STATE."
	BARKER_CURRENT_CHANNELS = "Canaux actuels :"
	BARKER_INVALID_CHANNEL_INDEX = "Index de canal invalide."
	BARKER_MAX_CHANNELS = "Nombre maximum de canaux atteint. Supprimez d'abord un canal."

	BARKER_ACTIVE_HOURS = "Heures actives : START à END"
	BARKER_DAY_TOGGLE = "DAY est maintenant STATE."

	BARKER_MAX_MESSAGES_REACHED = "Nombre maximum de messages envoyés. Barker désactivé."
	BARKER_MAX_MESSAGES_SET = "Limite maximale de messages définie à COUNT."
	BARKER_MAX_MESSAGES_UNLIMITED = "Pas de limite sur le nombre maximum de messages à envoyer."

	BARKER_ALTERNATE_ON = "Alternance des canaux activée. Les messages seront envoyés à un canal à la fois."
	BARKER_ALTERNATE_OFF = "Alternance des canaux désactivée. Les messages seront envoyés à tous les canaux simultanément."

	BARKER_SHOW_IN_CHAT_ON = "Les messages seront affichés dans le chat lors de l'envoi."
	BARKER_SHOW_IN_CHAT_OFF = "Les messages ne seront pas affichés dans le chat lors de l'envoi."

	BARKER_DEBUG_ON = "Mode débogage activé."
	BARKER_DEBUG_OFF = "Mode débogage désactivé."

	BARKER_UI_NOT_LOADED = "Le module d'interface n'est pas chargé."

	-- UI strings
	BARKER_ENABLE = "Activer Barker"
	BARKER_ENABLE_TT = "Activer ou désactiver l'envoi de messages"
	BARKER_BASE_RATE = "Intervalle d'envoi de base"
	BARKER_BASE_RATE_TT = "L'intervalle de base entre les messages en secondes"
	BARKER_RATE_VARIANCE = "Variance aléatoire"
	BARKER_RATE_VARIANCE_TT = "Secondes supplémentaires aléatoires à ajouter au taux de base (0-60)"
	BARKER_MAX_MESSAGES_LIMIT = "Max. messages à envoyer (0 = illimité) :"
	BARKER_ALTERNATE_CHANNELS = "Alterner entre les canaux"
	BARKER_ALTERNATE_CHANNELS_TT = "Au lieu d'envoyer à tous les canaux à la fois, alterner entre eux"
	BARKER_SHOW_IN_CHAT = "Afficher les messages dans le chat"
	BARKER_SHOW_IN_CHAT_TT = "Afficher les messages dans votre fenêtre de chat lorsqu'ils sont envoyés"
	BARKER_DEBUG = "Mode débogage"
	BARKER_DEBUG_TT = "Afficher des informations de débogage supplémentaires"

	BARKER_STATUS = "Statut"
	BARKER_MESSAGES_SENT = "Messages envoyés"

	BARKER_TAB_GENERAL = "Général"
	BARKER_TAB_MESSAGES = "Messages"
	BARKER_TAB_CHANNELS = "Canaux"
	BARKER_TAB_SCHEDULING = "Horaires"
	BARKER_TAB_HELP = "Aide"

	BARKER_MESSAGE_MODE = "Mode de rotation des messages :"
	BARKER_MODE_SEQUENTIAL = "Séquentiel"
	BARKER_MODE_RANDOM = "Aléatoire"
	BARKER_NEW_MESSAGE = "Ajouter un nouveau message :"
	BARKER_MESSAGE_LIST = "Liste des messages"
	BARKER_ADD = "Ajouter"
	BARKER_REMOVE = "Supprimer"

	BARKER_CHANNEL_TYPE = "Type de canal :"
	BARKER_CHANNEL_NUMBER = "Numéro de canal :"
	BARKER_CUSTOM_RATE = "Taux personnalisé pour ce canal"
	BARKER_CUSTOM_RATE_TT = "Définir un intervalle d'envoi personnalisé pour ce canal"
	BARKER_ADD_CHANNEL = "Ajouter un canal"
	BARKER_CHANNEL_LIST = "Liste des canaux"

	BARKER_ACTIVE_HOURS_LABEL = "Heures actives (format 24h) :"
	BARKER_START_HOUR = "Heure de début"
	BARKER_END_HOUR = "Heure de fin"
	BARKER_ACTIVE_DAYS = "Jours actifs :"

	BARKER_VERSION = "Version de Barker :"
	BARKER_ENABLED = "Activé"
	BARKER_DISABLED = "Désactivé"

-- Help text
BARKER_HELP = {
    "==================== Barker ====================",
    "Barker envoie périodiquement des messages dans un ou plusieurs canaux de discussion.",
    "Parfait pour annoncer des services, recruter pour des guildes, ou promouvoir des événements.",
    "",
    "Commandes de base :",
    "/bkr [on|off] : Démarrer/arrêter l'envoi de messages",
    "/bkrui : Ouvrir l'interface graphique",
    "/bkrinfo : Afficher les paramètres actuels",
    "",
    "Commandes de messages :",
    "/bkrmsg <message> : Ajouter un message à la rotation",
    "/bkrmsgdel <index> : Supprimer un message par index",
    "/bkrmode <sequential|random> : Définir le mode de rotation des messages",
    "",
    "Commandes de canaux :",
    "/bkrchan <canal> [taux] : Ajouter un canal avec taux personnalisé optionnel",
    "/bkrchandel <index> : Supprimer un canal par index",
    "/bkrchantog <index> : Activer/désactiver un canal",
    "",
    "Commandes de timing :",
    "/bkrrate <secondes> : Définir l'intervalle de base (min 10)",
    "/bkrvar <secondes> : Définir la variance de temps aléatoire (0-60)",
    "/bkrhours <début> <fin> : Définir les heures actives (0-24)",
    "/bkrday <1-7> : Basculer le jour (1=Dim, 7=Sam)",
    "/bkrmax <count> : Définir max messages (0=illimité)",
    "",
    "Autres commandes :",
    "/bkralt : Basculer l'alternance des canaux",
    "/bkrshow : Basculer l'affichage des messages dans le chat",
    "/bkrdebug : Basculer le mode débogage",
    "/bkrhelp : Afficher cette aide"
}
end
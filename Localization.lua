--[[----------------------------------------------------------------------------

  LiteMount/Localization.lua

  LiteMount translations into other languages.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

-- Vim reformatter from curseforge "Global Strings" export.
-- %s/^\(L\..*\) = \(.*\)/\=printf('%-24s= %s', submatch(1), submatch(2))/

_G.LM_Localize = setmetatable({ }, {__index=function (t,k) return k end})

local L = LM_Localize

local locale = GetLocale()

-- Automatic / Blizzard --------------------------------------------------------

L.CUSTOM1               = CUSTOM .. " 1"
L.CUSTOM2               = CUSTOM .. " 2"
L.FAVORITES             = FAVORITES
L.NAGRAND               = C_Map.GetMapInfo(550).name
L.VASHJIR               = C_Map.GetMapInfo(203).name

-- :r! sh fetchlocale.sh -------------------------------------------------------

-- enUS / enGB / Default -------------------------------------------------------

L.FLOAT                 = "Float"
L.FLY                   = "Fly"
L.LM_ADVANCED_EXP       = "These settings allow you to customize the actions run by each of the LiteMount key bindings. Please read the documentation at the URL below before changing anything."
L.LM_AUTHOR             = "Author"
L.LM_COMBAT_MACRO_EXP   = "If enabled, this macro will be run instead of the default combat actions if LiteMount is activated while you are combat."
L.LM_COPY_TARGETS_MOUNT = "Try to copy target's mount."
L.LM_CURRENT_SETTINGS   = "Current Settings"
L.LM_DEBUGGING_DISABLED = "Debugging disabled."
L.LM_DEBUGGING_ENABLED  = "Debugging enabled."
L.LM_DEFAULT_SETTINGS   = "Default Settings"
L.LM_DELETE_FLAG        = "Delete Flag"
L.LM_DELETE_PROFILE     = "Delete Profile"
L.LM_DISABLE_NEW_MOUNTS = "Automatically disable newly added mounts."
L.LM_DISABLING_MOUNT    = "Disabling active mount: %s"
L.LM_ENABLE_DEBUGGING   = "Enable debugging messages."
L.LM_ENABLING_MOUNT     = "Enabling active mount: %s"
L.LM_ERR_BAD_ACTION     = "Bad action '%s' in action list."
L.LM_ERR_BAD_CONDITION  = "Bad condition '%s' in action list."
L.LM_FLAGS              = "Flags"
L.LM_HELP_TRANSLATE     = "Help translate LiteMount into your language. Thank you."
L.LM_MACRO_EXP          = "This macro will be run if LiteMount is unable to find a usable mount. This might be because you are indoors, or are moving and don't know any instant-cast mounts."
L.LM_NEW_FLAG           = "New Flag"
L.LM_NEW_PROFILE        = "New Profile"
L.LM_PROFILES           = "Profiles"
L.LM_RENAME_FLAG        = "Rename Flag"
L.LM_RESET_PROFILE      = "Reset Profile"
L.LM_SETTINGS_TAGLINE   = "Simple and reliable random mount summoning."
L.LM_TRANSLATORS        = "Translators"
L.LM_WARN_REPLACE_COND  = "The [%s] action list condition has been replaced by [%s] due to Blizzard changes."
L.RUN                   = "Run"
L.SWIM                  = "Swim"
L.WALK                  = "Walk"

-- deDE ------------------------------------------------------------------------

if locale == "deDE" then
L.FLOAT                 = "Wasserwandeln"
L.FLY                   = "Fliegen"
L.LM_ADVANCED_EXP       = "Mit diesen Einstellungen können Sie die Aktionen anpassen, die von den einzelnen LiteMount-Tastenbindungen ausgeführt werden. Bitte lesen Sie die Dokumentation unter der folgenden URL, bevor Sie etwas ändern."
L.LM_AUTHOR             = "Autor"
L.LM_COMBAT_MACRO_EXP   = "Bei Aktivierung wird dieses Makro anstelle von normalen Kampfhandlungen benutzt, wenn LiteMount im Kampf verwendet wird."
L.LM_COPY_TARGETS_MOUNT = "Versuche, das Reittier deines Ziels zu kopieren."
L.LM_CURRENT_SETTINGS   = "Aktuelle Einstellungen"
L.LM_DEBUGGING_DISABLED = "Fehlersuche aus"
L.LM_DEBUGGING_ENABLED  = "Fehlersuche ein"
L.LM_DEFAULT_SETTINGS   = "Standardeinstellungen"
L.LM_DELETE_FLAG        = "Markierung löschen"
L.LM_DELETE_PROFILE     = "Profil löschen"
L.LM_DISABLE_NEW_MOUNTS = "Deaktiviere automatisch im Reittierführer neu entdeckte (aber noch nicht erlernte) Reittiere."
L.LM_DISABLING_MOUNT    = "Deaktiviere aktuelles Reittier: %s"
L.LM_ENABLE_DEBUGGING   = "Debug-Meldungen aktivieren."
L.LM_ENABLING_MOUNT     = "Aktiviere aktuelles Reittier: %s"
L.LM_ERR_BAD_ACTION     = "Schlechte Aktion '%s' in der Aktionsliste."
L.LM_ERR_BAD_CONDITION  = "Schlechte Bedingung '%s' in der Aktionsliste."
L.LM_FLAGS              = "Markierungen"
L.LM_HELP_TRANSLATE     = "Hilf dabei, LiteMount in deine Sprache zu übersetzen. Danke."
L.LM_MACRO_EXP          = "Dieses Makro wird ausgeführt, wenn LiteMount kein nutzbares Reittier findet. Dies kann passieren, wenn du dich in Gebäuden aufhältst oder läufst und keine spontan wirkbaren Reittiere hast."
L.LM_NEW_FLAG           = "Markierung hinzufügen"
L.LM_NEW_PROFILE        = "Neues Profil"
L.LM_PROFILES           = "Profile"
L.LM_RENAME_FLAG        = "Markierung umbenennen"
L.LM_RESET_PROFILE      = "Profil zurücksetzen"
L.LM_SETTINGS_TAGLINE   = "Einfaches und zuverlässiges Beschwören von zufälligen Reittieren."
L.LM_TRANSLATORS        = "Übersetzer"
L.LM_WARN_REPLACE_COND  = "Die Bedingung der [%s] -Aktionsliste wurde aufgrund von Blizzard-Änderungen durch [%s] ersetzt."
L.RUN                   = "Rennen"
L.SWIM                  = "Schwimmen"
L.WALK                  = "Laufen"
end

-- esES / esMX -----------------------------------------------------------------

if locale == "esES" or locale == "esMX" then
L.FLOAT                 = "Flotador"
L.FLY                   = "Volar"
L.LM_ADVANCED_EXP       = "Estas configuraciones le permiten personalizar las acciones ejecutadas por cada uno de los acciones clave de LiteMount. Lea la documentación en la URL a continuación antes de cambiar cualquier cosa."
L.LM_AUTHOR             = "Auto"
L.LM_COMBAT_MACRO_EXP   = "Si está habilitado, esta macro se ejecutará en lugar de las acciones de combate predeterminadas si LiteMount se activa mientras estás en combate."
L.LM_COPY_TARGETS_MOUNT = "Intenta copiar la montura del objetivo."
L.LM_CURRENT_SETTINGS   = "Configuraciones actuales"
L.LM_DEBUGGING_DISABLED = "Depuración desactivada."
L.LM_DEBUGGING_ENABLED  = "Depuración activada."
L.LM_DEFAULT_SETTINGS   = "Configuración por defecto"
L.LM_DELETE_FLAG        = "Borrar un marbete"
L.LM_DELETE_PROFILE     = "Borrar un perfil"
L.LM_DISABLE_NEW_MOUNTS = "Deshabilitar automáticamente las monturas recién agregados."
L.LM_DISABLING_MOUNT    = "Desactivar la montura activa: %s"
L.LM_ENABLE_DEBUGGING   = "Activar los mensajes de depuración."
L.LM_ENABLING_MOUNT     = "Activando el montaje activo: %s"
L.LM_ERR_BAD_ACTION     = "Mala acción '%s' en la lista de acciones."
L.LM_ERR_BAD_CONDITION  = "Mala estado '%s' en la lista de acciones."
L.LM_FLAGS              = "Marbetes"
L.LM_HELP_TRANSLATE     = "Ayuda a traducir LiteMount a tu idioma. Gracias."
L.LM_MACRO_EXP          = "Esta macro se ejecutará si LiteMount no puede encontrar una montura utilizable. Esto podría deberse a que está en el interior, o se está moviendo, y no conoce ningún montaje instantáneo."
L.LM_NEW_FLAG           = "Crear un marbete"
L.LM_NEW_PROFILE        = "Crear un perfil"
L.LM_PROFILES           = "Perfiles"
L.LM_RENAME_FLAG        = "Cambiar un marbete"
L.LM_RESET_PROFILE      = "Reiniciar perfil"
L.LM_SETTINGS_TAGLINE   = "Invocación de monturas aleatorio simple y confiable."
L.LM_TRANSLATORS        = "Traductores"
L.LM_WARN_REPLACE_COND  = "La condición de la lista de acciones [%s] ha sido reemplazada por [%s] debido a los cambios de Blizzard."
L.RUN                   = "Correr"
L.SWIM                  = "Nadar"
L.WALK                  = "Caminar"
end

-- frFR ------------------------------------------------------------------------

if locale == "frFR" then
L.FLOAT                 = "Flotte"
L.FLY                   = "Vol"
L.LM_ADVANCED_EXP       = "Ces paramètres vous permettent de customiser les actions lancées par chacun des raccourcis de LiteMount. Veillez à lire la documentation jointe à l’URL ci-dessous avant de changer quoique ce soit."
L.LM_AUTHOR             = "Auteur"
L.LM_COMBAT_MACRO_EXP   = "Si cochée, cette macro sera lancée à la place de l'action de combat par défaut si LiteMount est actif lorsque vous êtes en combat."
L.LM_COPY_TARGETS_MOUNT = "Essaye de copier la monture de la cible."
L.LM_CURRENT_SETTINGS   = "Réglages actuels"
L.LM_DEBUGGING_DISABLED = "Débogage désactivé."
L.LM_DEBUGGING_ENABLED  = "Débogage activé."
L.LM_DEFAULT_SETTINGS   = "Réglages par défaut"
L.LM_DELETE_FLAG        = "Supprimer le Tag"
L.LM_DELETE_PROFILE     = "Effacer le profil"
L.LM_DISABLE_NEW_MOUNTS = "Désactive automatiquement les montures nouvellement ajoutées."
L.LM_DISABLING_MOUNT    = "Désactivation de la monture courante: %s"
L.LM_ENABLE_DEBUGGING   = "Activer les messages de débogage."
L.LM_ENABLING_MOUNT     = "Activation de la monture courante: %s"
L.LM_ERR_BAD_ACTION     = "Mauvaise action '%s' dans la liste d'actions."
L.LM_ERR_BAD_CONDITION  = "Mauvaise condition '%s' dans la liste des actions."
L.LM_FLAGS              = "Tags"
L.LM_HELP_TRANSLATE     = "Aidez a traduire LiteMount dans votre langue. Merci."
L.LM_MACRO_EXP          = "Cette macro sera exécutée si LiteMount ne trouve pas de monture utilisable. Cela peut arriver si vous êtes en intérieur, ou si vous bougez et n'avez pas de monture instantanée."
L.LM_NEW_FLAG           = "Nouveau Tag"
L.LM_NEW_PROFILE        = "Créer un profil"
L.LM_PROFILES           = "Profils"
L.LM_RENAME_FLAG        = "Renommer le Tag"
L.LM_RESET_PROFILE      = "Réinitialiser le profil"
L.LM_SETTINGS_TAGLINE   = "Invocation simple et fiable de monture aléatoire."
L.LM_TRANSLATORS        = "Traducteurs"
L.LM_WARN_REPLACE_COND  = "La condition de la liste d'actions [%s] a été remplacée par [%s] en raison de changements de Blizzard."
L.RUN                   = "Cours"
L.SWIM                  = "Nage"
L.WALK                  = "Marche"
end

-- itIT ------------------------------------------------------------------------

if locale == "itIT" then
L.FLOAT                 = "Float"
L.FLY                   = "Vola"
L.LM_ADVANCED_EXP       = "Queste impostazioni consentono di personalizzare le azioni di ciascun binding di chiavi LiteMount.\" Leggere la documentazione all'URL sottostante prima di modificare qualsiasi cosa."
L.LM_AUTHOR             = "Autore"
L.LM_COMBAT_MACRO_EXP   = "Se abilitato, questa macro verrà eseguita al posto delle azioni di combattimento predefinite se LiteMount viene attivato mentre sei in combattimento."
L.LM_COPY_TARGETS_MOUNT = "Prova a copiare la montatura del bersaglio."
L.LM_CURRENT_SETTINGS   = "Impostazioni attuali"
L.LM_DEBUGGING_DISABLED = "Debug disabilitato."
L.LM_DEBUGGING_ENABLED  = "Debug abilitato."
L.LM_DEFAULT_SETTINGS   = "Impostazioni predefinite"
L.LM_DELETE_FLAG        = "Cancella un'etichetta"
L.LM_DELETE_PROFILE     = "Cancella un Profilo"
L.LM_DISABLE_NEW_MOUNTS = "Disattiva automaticamente i mount appena aggiunti."
L.LM_DISABLING_MOUNT    = "Disabilitazione del montaggio attivo: %s"
L.LM_ENABLE_DEBUGGING   = "Attiva messaggi di debug."
L.LM_ENABLING_MOUNT     = "Abilitazione del montaggio attivo: %s"
L.LM_ERR_BAD_ACTION     = "Azione non valida '%s' nella lista di azioni."
L.LM_ERR_BAD_CONDITION  = "Cattiva condizione '%s' nella lista di azioni."
L.LM_FLAGS              = "Etichette"
L.LM_HELP_TRANSLATE     = "Aiuta a tradurre LiteMount nella tua lingua. Grazie."
L.LM_MACRO_EXP          = "Questa macro verrà eseguito se LiteMount non è in grado di trovare un supporto utilizzabile. Questo potrebbe essere perché siete al chiuso, o si muove e non si conosce alcun supporti istantanea del cast."
L.LM_NEW_FLAG           = "Crea un'etichetta"
L.LM_NEW_PROFILE        = "Crea un profilo"
L.LM_PROFILES           = "Profili"
L.LM_RENAME_FLAG        = "Rinominare un'etichetta"
L.LM_RESET_PROFILE      = "Reimposta Profilo"
L.LM_SETTINGS_TAGLINE   = "Convocazione a montaggio casuale semplice e affidabile."
L.LM_TRANSLATORS        = "Traduttore"
L.LM_WARN_REPLACE_COND  = "Il [s%] condizione lista di azioni è stata sostituita da [%s] a causa di cambiamenti Blizzard."
L.RUN                   = "Esegui"
L.SWIM                  = "Swim"
L.WALK                  = "Cammina"
end

-- koKR ------------------------------------------------------------------------

if locale == "koKR" then
L.FLOAT                 = "수면 보행"
L.FLY                   = "비행"
L.LM_ADVANCED_EXP       = "이 설정을 통해 각 LiteMount 키 바인딩이 실행하는 작업을 사용자 정의 할 수 있습니다. 아무 것도 변경하기 전에 아래 URL의 설명서를 읽어보십시오."
L.LM_AUTHOR             = "저자"
L.LM_COMBAT_MACRO_EXP   = "활성화하면 당신이 전투 중일때 LiteMount가 활성화되면 기본 전투 행동 대신 이 매크로가 실행됩니다."
L.LM_COPY_TARGETS_MOUNT = "대상의 탈것을 따라하도록 시도합니다."
L.LM_CURRENT_SETTINGS   = "현재 설정"
L.LM_DEBUGGING_DISABLED = "디버깅이 비활성화되었습니다."
L.LM_DEBUGGING_ENABLED  = "디버깅이 활성화되었습니다."
L.LM_DEFAULT_SETTINGS   = "기본 설정"
L.LM_DELETE_FLAG        = "조건 삭제"
L.LM_DELETE_PROFILE     = "프로필 삭제"
L.LM_DISABLE_NEW_MOUNTS = "새로 추가된 탈것을 자동으로 비활성합니다."
L.LM_DISABLING_MOUNT    = "현재 탈것 비활성: %s"
L.LM_ENABLE_DEBUGGING   = "디버깅 메시지를 출력합니다."
L.LM_ENABLING_MOUNT     = "현재 탈것 활성화: %s"
L.LM_ERR_BAD_ACTION     = "작업 목록의 작업 '%s' 이 (가) 잘못되었습니다."
L.LM_ERR_BAD_CONDITION  = "작업 목록의 조건 '%s' 이 (가) 잘못되었습니다."
L.LM_FLAGS              = "조건"
L.LM_HELP_TRANSLATE     = "당신의 언어로 LiteMount 번역을 도와주세요. 감사합니다."
L.LM_MACRO_EXP          = "LiteMount가 사용 가능한 탈것을 찾을 수 없을 때 실행될 매크로입니다. 실내에 있거나 이동 중이면서 즉시 시전 탈것이 없을 때 사용 됩니다."
L.LM_NEW_FLAG           = "조건 생성"
L.LM_NEW_PROFILE        = "새로운 프로필"
L.LM_PROFILES           = "프로필"
L.LM_RENAME_FLAG        = "조건 이름 바꾸기"
L.LM_RESET_PROFILE      = "프로필 초기화"
L.LM_SETTINGS_TAGLINE   = "간단하게 믿을 수 있는 무작위 탈것을 소환합니다."
L.LM_TRANSLATORS        = "번역가"
L.LM_WARN_REPLACE_COND  = "블리자드 변경으로 인해 [%s] 작업 목록 조건이 [%s] (으)로 바뀌 었습니다."
L.RUN                   = "지상"
L.SWIM                  = "수중"
L.WALK                  = "걷기"
end

-- ptBR ------------------------------------------------------------------------

if locale == "ptBR" then
L.FLOAT                 = "Flutuar"
L.FLY                   = "Voar"
L.LM_ADVANCED_EXP       = "Essas configurações permitem personalizar as ações executadas por cada uma das teclas de atalho do LiteMount. Por favor, leia a documentação no URL abaixo antes de alterar qualquer coisa."
L.LM_AUTHOR             = "Autor"
L.LM_COMBAT_MACRO_EXP   = "Se habilitada, esta macro será executada em vez das ações de combate padrão se o LiteMount for ativado enquanto você estiver em combate."
L.LM_COPY_TARGETS_MOUNT = "Tentra copiar a montaria do alvo."
L.LM_CURRENT_SETTINGS   = "Configuração Atual"
L.LM_DEBUGGING_DISABLED = "Depuração desativada."
L.LM_DEBUGGING_ENABLED  = "Depuração ativada."
L.LM_DEFAULT_SETTINGS   = "Configuração Padrão"
L.LM_DELETE_FLAG        = "Remover um rótulo"
L.LM_DELETE_PROFILE     = "Remover um Perfil"
L.LM_DISABLE_NEW_MOUNTS = "Desativar automaticamente montagens recém-adicionadas."
L.LM_DISABLING_MOUNT    = "Desativando a montagem ativa: %s"
L.LM_ENABLE_DEBUGGING   = "Permite mensagens de depuração."
L.LM_ENABLING_MOUNT     = "Ativando a montagem ativa: %s"
L.LM_ERR_BAD_ACTION     = "Má ação '%s' na lista de ações."
L.LM_ERR_BAD_CONDITION  = "Condição ruim '%s' na lista de ações."
L.LM_FLAGS              = "Rótulos"
L.LM_HELP_TRANSLATE     = "Ajude a traduzir o LiteMount para o seu idioma. Obrigado."
L.LM_MACRO_EXP          = "Esta macro será executada se o LiteMount não conseguir encontrar uma montagem utilizável. Isso pode ser porque você está dentro de casa, ou está se movendo e não conhece nenhuma montagem instantânea."
L.LM_NEW_FLAG           = "Crie um rótulo"
L.LM_NEW_PROFILE        = "Cria um perfil"
L.LM_PROFILES           = "Perfis"
L.LM_RENAME_FLAG        = "Renomear um rótulo"
L.LM_RESET_PROFILE      = "Resetar Perfil"
L.LM_SETTINGS_TAGLINE   = "Montagem aleatória simples e confiável de montagem."
L.LM_TRANSLATORS        = "Tradutores"
L.LM_WARN_REPLACE_COND  = "A condição da lista de ações [%s] foi substituída por [%s] devido a alterações da Blizzard."
L.RUN                   = "Correr"
L.SWIM                  = "Nadar"
L.WALK                  = "Andar"
end

-- ruRU ------------------------------------------------------------------------

if locale == "ruRU" then
L.FLOAT                 = "плавучий"
L.FLY                   = "летающий"
L.LM_ADVANCED_EXP       = "Эти настройки позволяют настраивать действия, выполняемые каждым из привязок клавиш LiteMount. Прочтите документацию по URL-адресу ниже, прежде чем что-либо менять."
L.LM_AUTHOR             = "Aвтор"
L.LM_COMBAT_MACRO_EXP   = "Если этот параметр включен, этот макрос будет запускаться вместо боевых действий по умолчанию, если LiteMount активируется во время боя."
L.LM_COPY_TARGETS_MOUNT = "Попробуйте скопировать монтирование цели."
L.LM_CURRENT_SETTINGS   = "текущие настройки"
L.LM_DEBUGGING_DISABLED = "Отладка отключена."
L.LM_DEBUGGING_ENABLED  = "Отладка включена."
L.LM_DEFAULT_SETTINGS   = "Настройки по умолчанию"
L.LM_DELETE_FLAG        = "удалить тег"
L.LM_DELETE_PROFILE     = "Удалить профиль"
L.LM_DISABLE_NEW_MOUNTS = "Автоматически отключать недавно добавленные монтирования."
L.LM_DISABLING_MOUNT    = "Отключение активного монтирования: %s"
L.LM_ENABLE_DEBUGGING   = "Включить отладочную информацию"
L.LM_ENABLING_MOUNT     = "Включение активного монтирования: %s"
L.LM_ERR_BAD_ACTION     = "Плохое действие «%s» в списке действий."
L.LM_ERR_BAD_CONDITION  = "Плохое состояние «%s» в списке действий."
L.LM_FLAGS              = "теги"
L.LM_HELP_TRANSLATE     = "Помогите перевести LiteMount на ваш язык. Спасибо."
L.LM_MACRO_EXP          = "Этот макрос будет запущен, если LiteMount не сможет найти пригодное для использования монтирование. Это может быть из-за того, что вы находитесь в помещении или двигаетесь и не знаете никаких монстров с мгновенным литом."
L.LM_NEW_FLAG           = "создать тег"
L.LM_NEW_PROFILE        = "Новый профиль"
L.LM_PROFILES           = "Профили"
L.LM_RENAME_FLAG        = "Переименовать тег"
L.LM_RESET_PROFILE      = "Сброс профиль"
L.LM_SETTINGS_TAGLINE   = "Простое и надежное случайное монтирование."
L.LM_TRANSLATORS        = "Переводчики"
L.LM_WARN_REPLACE_COND  = "Условие списка [% s] заменено на [% s] из-за изменений Blizzard."
L.RUN                   = "беговой"
L.SWIM                  = "плавательный"
L.WALK                  = "ходячий"
end

-- zhCN ------------------------------------------------------------------------

if locale == "zhCN" then
L.FLOAT                 = "浮动"
L.FLY                   = "飞"
L.LM_ADVANCED_EXP       = "这些设置允许您自定义每个LiteMount键绑定运行的操作。在更改任何内容之前，请阅读以下URL中的文档。"
L.LM_AUTHOR             = "作者"
L.LM_COMBAT_MACRO_EXP   = "如启用，LiteMount被激活并且当你在战斗中，该宏会被运行替代默认战斗动作。"
L.LM_COPY_TARGETS_MOUNT = "尝试复制目标的坐骑。"
L.LM_CURRENT_SETTINGS   = "当前的设置"
L.LM_DEBUGGING_DISABLED = "调试已禁用"
L.LM_DEBUGGING_ENABLED  = "调试已启用"
L.LM_DEFAULT_SETTINGS   = "默认设置"
L.LM_DELETE_PROFILE     = "删除一个配置文件"
L.LM_ENABLE_DEBUGGING   = "启用调试消息。"
L.LM_HELP_TRANSLATE     = "帮助将LiteMount翻译成您的语言。谢谢。"
L.LM_MACRO_EXP          = "如果LiteMount不能找到可用的坐骑会用到此宏，这可能是因为你在室内，或者正在移动中，并且不会任何瞬发坐骑。"
L.LM_NEW_PROFILE        = "新建一个配置文件"
L.LM_PROFILES           = "配置文件"
L.LM_RESET_PROFILE      = "重置配置文件"
L.LM_TRANSLATORS        = "译者"
L.RUN                   = "跑"
L.SWIM                  = "游"
L.WALK                  = "步行"
end

-- zhTW ------------------------------------------------------------------------

if locale == "zhTW" then
L.FLY                   = "飛行"
L.LM_AUTHOR             = "作者"
L.LM_COMBAT_MACRO_EXP   = "如果啟用，此巨集將替代預設的戰鬥行動，如果LiteMount是啟用的而且你在戰鬥中。"
L.LM_DELETE_PROFILE     = "刪除一個設定檔"
L.LM_ENABLE_DEBUGGING   = "啟用除錯訊息。"
L.LM_MACRO_EXP          = "此巨集將被運作在如果LiteMount無法找到一個可用的坐騎，這有可能是由於你在室內，或在移動中並且沒有任何可瞬間招換的坐騎。"
L.LM_NEW_PROFILE        = "新建一的設定檔"
L.LM_PROFILES           = "設定檔"
L.LM_RESET_PROFILE      = "重置設定檔"
L.LM_TRANSLATORS        = "譯者"
L.RUN                   = "陸地"
L.SWIM                  = "水中"
end

/* 
Доделать вывод сообщений в чат, кто зашел и на кого переименовлся
Доделать запись в файл (при флаге амина) из чата нового имени по /addnewname %name%
Доделать показ имен, при написании /shownames в MOTD окно

*/
 
#include <amxmodx>
#include <amxmisc>

#define PLUGIN						"AMXx Player Renamer"
#define VERSION						"1.7.5"
#define AUTHOR						"EpicMorg"
#define TASK_SHOWINFO_BASE			100
#define DELAY_BEFORE_INFO			5.0
#define MAX_PLAYERS					32

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("renamer_permanent","0"); //Жесткое переименование. Сохраняется при выходе с сервера. Не желательно, тк неадекватно работает в Steam-клиентах.
	register_cvar("renamer_checkonconnect","1"); //Проверка на имя при подключении игрока. Вкл. по умолчанию.
	register_cvar("renamer_checkondeath","1");  //Проверка на имя при смерти игрока. Вкл. по умолчанию.
	register_cvar("renamer_checkinterval","0"); //Проверка на имя каждые n секунд. 0 - выключено, по умолчанию. 
    register_clcmd("say /showbannednames","bannednames_motd"); //Показывать MOTD-окно с забаненными именами.
	register_clcmd("say /sbn","bannednames_motd"); //Показывать MOTD-окно с забаненными именами.
	//register_clcmd("say /addbannedname %s","bannednames_add"); //Вызывает функцию bannednames_add с добавлением номого имени
	log_amx("[AMXx Renamer] Loaded!");
}

public get_configfile_name(path){
	new name_file[256];
	get_configsdir(name_file, 256);
	add(name_file, 256, path);
	return name_file;
}

public get_namefile_name(){ 
	return get_configfile_name("/renamer/renamer_names.ini"); 
}

public get_banfile_name(){ 
	return get_configfile_name("/renamer/renamer_banned.ini");
}
 
public check_path_and_files(){
	new namefile_path = get_namefile_name(); 
	new banfile_path = get_banfile_name(); 
	
	if (!file_exists(namefile_path)){
		log_amx("[AMXx Renamer] .../renamer/renamer_names.ini is missing!");
		return 0;
	}
	if (!file_exists(banfile_path)){
		log_amx("[AMXx Renamer] .../renamer/renamer_banned.ini is missing!");
		return 0;
	}
	return 1;
}

public bannednames_motd(id){  
    show_motd(id,"Sorry. Comming soon","Banned Names")
} 

public renamer(id){
	if (!check_path_and_files()){
		return;
	}
	new name_file = get_namefile_name(); 
	//работаем с именами из словаря 
	new lines_in_name_file = file_size(name_file,1); //Получение количества строк из name-файла
	new random = random_num(0,lines_in_name_file -1); //Получение случайной строки между 0 и последней
	new txt_length_name; //Резерв
	new NewName[256]; //Случайное имя
	read_file(name_file,random,NewName,256,txt_length_name); 
	//работаем с забанеными именами и имнем клиента
	new ban_file = get_banfile_name();
	new BannedName[256]; //Заблокированное имя
	//Получение количества строк из ban-файла
	new lines_in_ban_file = file_size(ban_file,1) 
	new i = 0;
	for(i = 0; i <= lines_in_ban_file; i++){
		new current_player_name[256];
		get_user_name(id, current_player_name, 256);
		read_file(ban_file,i,BannedName,256,txt_length_name);
		if(equali(current_player_name, BannedName)){
			//Условие что наш квар больше нуля
			if (get_cvar_num("renamer_permanent") != 0){
				client_cmd(id, "name %s", NewName);
				log_amx("[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);
				client_cmd(id, "reconnect"); //Fix для steam client 
				client_print(id,print_chat,"[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);   
				client_print(id,print_console,"[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);
				client_print(id,print_notify,"[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);
			}
			else {
				//Если 0, то менять ник только на время игры на текущей карте
				set_user_info(id, "name", NewName);
				log_amx("[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);
				client_print(id,print_chat,"[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);   
				client_print(id,print_console,"[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);
				client_print(id,print_notify,"[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);
			}
			break;
		}
	}
}

public client_connect(id){  
	if (get_cvar_num("renamer_checkonconnect") = 1){
		renamer(id); 
	}
}

public ShowInfo(id)
{
	id -= TASK_SHOWINFO_BASE;
	if (id < 1 || id > MAX_PLAYERS) return;

	//client_print(id,print_chat,"[AMXx Renamer] Test!");  
	//client_print(id,print_console,"[AMXx Renamer] Test!"); 
	//client_print(id,print_notify,"[AMXx Renamer] Test!"); 
}

public client_putinserver(id) 
{ 
	set_task(DELAY_BEFORE_INFO, "ShowInfo", TASK_SHOWINFO_BASE + id); 
}
 

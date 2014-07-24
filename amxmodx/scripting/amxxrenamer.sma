/*

Исправить (или отказаться) от перманентного переименования
Доделать вывод сообщений в чат, кто зашел и на кого переименовлся
Доделать запись в файл (при флаге амина) из чата нового имени по /addnewname %name%
Доделать показ имен, при написании /shownames в MOTD окно

*/
 
#include <amxmodx>
#include <amxmisc>
#define PLUGIN "Player Renamer"
#define VERSION "1.7.4"
#define AUTHOR "EpicMorg"
#define TASK_SHOWINFO_BASE			100
#define DELAY_BEFORE_INFO			5.0
#define MAX_PLAYERS				32
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("renamer_permanent","0")
	log_amx("[AMXx Renamer] Loaded!");
}
public client_authorized(id)
{
	//работаем с именами из словаря 
	new name_file[256];
	get_configsdir(name_file, 256);
	add(name_file, 256, "/renamer_names.ini");
	if (!file_exists(name_file))
	{
		log_amx("[AMXx Renamer] amxmodx/configs/renamer_names.ini is missing!");
		return;
	}
	new lines_in_name_file = file_size(name_file,1); //Получение количества строк из name-файла
	new random = random_num(0,lines_in_name_file -1); //Получение случайной строки между 0 и последней
	new txt_length_name; //Резерв
	new NewName[256]; //Случайное имя
	read_file(name_file,random,NewName,256,txt_length_name);
	//работаем с забанеными именами и имнем клиента
	new ban_file[256];
	get_configsdir(ban_file, 256);
	add(ban_file, 256, "/renamer_banned.ini");
	new BannedName[256]; //Заблокированное имя
	if (!file_exists(ban_file))
	{
		log_amx("[AMXx Renamer] amxmodx/configs/renamer_banned.ini is missing!");
		return;
	}
	new lines_in_ban_file = file_size(ban_file,1) //Получение количества строк из ban-файла
	new i = 0;
	for(i = 0; i <= lines_in_ban_file; i++)
	{
		new current_player_name[256];
		get_user_name(id, current_player_name, 256);
		//trim(current_player_name);
		read_file(ban_file,i,BannedName,256,txt_length_name);
		if(equali(current_player_name, BannedName)){
			//Условие что наш квар больше нуля
			if (get_cvar_num("renamer_permanent") != 0){
				client_cmd(id, "name %s", NewName);
				log_amx("[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);
				client_cmd(id, "reconnect"); //Fix для steam client 
				//client_print(id,print_chat,"[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);   
				//client_print(id,print_console,"[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);
				//client_print(id,print_notify,"[AMXx Renamer] Player %s renamed permanently to %s!", current_player_name, NewName);
			}
			else {
				//Если 0, то менять ник только на время игры на текущей карте
				set_user_info(id, "name", NewName);
				log_amx("[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);
				//client_print(id,print_chat,"[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);   
				//client_print(id,print_console,"[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);
				//client_print(id,print_notify,"[AMXx Renamer] Player %s renamed temporary to %s!", current_player_name, NewName);
			}
			break;
		}
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
 


#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;	
	
	Наименование = NAME;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Облигации.Код
		|ИЗ
		|	Справочник.Облигации КАК Облигации
		|ГДЕ
		|	Облигации.Ссылка <> &Ссылка
		|	И Облигации.SECID = &SECID
		|	И Облигации.ПометкаУдаления = ЛОЖЬ";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("SECID", SECID);
	
	Если НЕ Запрос.Выполнить().Пустой() Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						        	НСтр("ru='Тикер с SECID <%1> уже присутствует в справочнике'"),
						        	SECID);
	КонецЕсли;
КонецПроцедуры
#КонецОбласти



#Область СлужебныйПрограммныйИнтерфейс
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
Процедура ЗагрузитьС_MOEX(Текст) Экспорт
//			"RU000A100WA8", 
	Тикер = ?(Текст=Неопределено, SECID, Текст);
	URL = СтрШаблон(
			"%1/%2.json?%3",
			"https://iss.moex.com/iss/securities",
			Тикер,
			"iss.meta=off&iss.only=description,boards&primary_board=1&iss.json=extended"
		);


	ДопПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	//@skip-check bsl-legacy-check-returning-type-for-environment
	Ответ = КлиентHTTPКлиентСервер.ТелоОтветаКакJSON(ДопПараметры).Получить(URL, , ДопПараметры);
	
	Если Ответ.КодСостояния <> 200 Тогда
		ТекстПредупреждения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						        	НСтр("ru='Ошибка получения данных с биржи. Код ответа <%1>'"),
						        	Ответ.КодСостояния);
		#Если Сервер Тогда
		ОбщегоНазначения.СообщитьПользователю(ТекстПредупреждения);		
		#КонецЕсли						        	
		Возврат;		
	КонецЕсли;
	
	ТелоОтвета = Ответ.Тело[1];
	РеквизитыОбъекта = Метаданные().Реквизиты; 
	
	Если ТелоОтвета.description.Количество() = 0 Тогда
		#Если Сервер Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru='Ошибка получения данных с биржи. Тикер не найден111'"));		
		#КонецЕсли						        	
		Возврат;		
	КонецЕсли;
	
	Для Каждого эл Из ТелоОтвета.description Цикл
		Если РеквизитыОбъекта.Найти(эл.name) = Неопределено Тогда
			Продолжить;			
		КонецЕсли;
		
		Если эл.type = "date" Тогда
			ЭтотОбъект[эл.name] = ПрочитатьДатуJSON(эл.value, ФорматДатыJSON.ISO);
		ИначеЕсли эл.type = "boolean" Тогда
			ЭтотОбъект[эл.name] = ?(эл.value = "1", Истина, Ложь);		
		Иначе
			ЭтотОбъект[эл.name] = эл.value;
		КонецЕсли;		
	КонецЦикла;
	Наименование = NAME;
	
	BOARDID = ТелоОтвета.boards[0].boardid;	
КонецПроцедуры
#Иначе
  ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
#КонецОбласти

options(scipen = 999)

packages <- c('dplyr', 'readxl', 'reshape2', 'tidyr', 'stringr', 'writexl', 'openxlsx')

new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(packages, library, character.only = T)

rm(list = ls())

`%notin%` <- Negate(`%in%`)

Ingresos_Codigos <- read_excel("Datos/Cuentas.xlsx", sheet = "Ingresos")
Costos_Codigos_Contributivo <- read_excel("Datos/Cuentas.xlsx", sheet = "Costos_Contributivo")
Costos_Codigos_Subsidiado <- read_excel("Datos/Cuentas.xlsx", sheet = "Costos_Subsidiado")
Costos_Codigos_Reservas <- read_excel("Datos/Cuentas.xlsx", sheet = "Reservas_Tecnicas")
Liberacion_Codigos <- read_excel("Datos/Cuentas.xlsx", sheet = "Liberacion")

Ingresos_Codigos$COD <- as.character(Ingresos_Codigos$COD)
Ingresos_Codigos$niif <- as.character(Ingresos_Codigos$niif)

Costos_Codigos_Contributivo$COD <- as.character(Costos_Codigos_Contributivo$COD)
Costos_Codigos_Contributivo$niif <- as.character(Costos_Codigos_Contributivo$niif)

Costos_Codigos_Subsidiado$COD <- as.character(Costos_Codigos_Subsidiado$COD)
Costos_Codigos_Subsidiado$niif <- as.character(Costos_Codigos_Subsidiado$niif)

Costos_Codigos_Reservas$COD <- as.character(Costos_Codigos_Reservas$COD)
Costos_Codigos_Reservas$niif <- as.character(Costos_Codigos_Reservas$niif)

Liberacion_Codigos$COD <- as.character(Liberacion_Codigos$COD)
Liberacion_Codigos$niif <- as.character(Liberacion_Codigos$niif)

Consolidado <- NULL

periodo <- c(2017, 2018, 2019, 2020, 2021)

for (i in periodo) {
 
  #-------------------------------------------------------------------------------
  #                     Section 1. Load databases and adjust
  #-------------------------------------------------------------------------------
  
  # Load databases ####
  
  g1 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-01", skip = 17)
  g2 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-02", skip = 17)
  g6 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-06", skip = 17)
  g7 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-07", skip = 17)
  g8 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-08", skip = 17)
  EPS <- read_excel(paste0("./Datos/Originales/",i,".xlsx"),  sheet = "Hoja1")
  
  if(i == "2019"){
    g7_1 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-07_1", skip = 17)
  }else if(i == "2020"){
    g2_1 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-02_1", skip = 17)
  }else if(i == "2021"){
    g1_1 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-01_1", skip = 17)
    g2_1 <- read_excel(paste0("./Datos/Originales/",i,".xlsx"), sheet = "FT001-02_1", skip = 17)
  }
  
  # Organize databases ####
  
  g1 <- g1 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  g2 <- g2 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  g6 <- g6 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  g7 <- g7 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  g8 <- g8 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  
  if(i == "2019"){
    g7_1 <- g7_1 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  }else if(i == "2020"){
    g2_1 <- g2_1 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  }else if(i == "2021"){
    g1_1 <- g1_1 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
    g2_1 <- g2_1 %>% pivot_longer(cols=starts_with(c("8","9")),names_to="EPS",values_to="cost")  %>% dplyr::filter(!is.na(LENGTH))
  }
  
  # Join in the same table #### 
  
  if(i == "2019"){
    base <- rbind(g1,g2,g6,g7,g8,g7_1)
    rm(g1,g2,g6,g7,g8,g7_1)
  }else if(i == "2020"){
    base <- rbind(g1,g2,g6,g7,g8,g2_1)
    rm(g1,g2,g6,g7,g8,g2_1)
  }else if(i == "2021"){
    base <- rbind(g1,g2,g6,g7,g8,g1_1,g2_1)
    rm(g1,g2,g6,g7,g8,g1_1,g2_1)
  }else{
    base <- rbind(g1,g2,g6,g7,g8)
    rm(g1,g2,g6,g7,g8)
  }
  
  colnames(base)[6] <- colnames(EPS)[2]
  base <- left_join(base,EPS,by="NIT")
  
  # Modify group according to resolution ####
  
  base <- base %>% rename(GRUPO = `GRUPO:`)
  
  base <- base %>% mutate(GRUPO = ifelse(str_starts(GRUPO,"Res. 743")==TRUE,6,GRUPO))
  base <- base %>% mutate(GRUPO = ifelse(str_starts(GRUPO,"Res. 414")==TRUE,7,GRUPO))
  base <- base %>% mutate(GRUPO = ifelse(str_starts(GRUPO,"Res. 533")==TRUE,8,GRUPO))
  
  if(i == "2017"){
    base <- base %>% filter(NIT %notin% c('890303093', '860066942', '890904996', '800112806'))
  }else if(i == "2018"){
    base <- base %>% filter(NIT %notin% c('890303093', '860066942', '800112806'))
  }else if(i == "2019"){
    base <- base %>% filter(NIT %notin% c('890303093', '860066942', '800112806', '817001773'))
  }else if(i == "2021"){
    base <- base %>% filter(NIT %notin% c('890904996'))
  }else{
    base <- base
  }
  
  #-------------------------------------------------------------------------------
  #                     Section 2. Calculation of income and costs
  #-------------------------------------------------------------------------------
  
  ################################################################################
  #############################  Contributory regime    #########################
  ################################################################################
  
  # Incomes ####
  
  ingresos_rc_niif_1_2 <- base %>% dplyr::filter(GRUPO %in% c(1,2))
  ingresos_rc_niif_1_2 <- ingresos_rc_niif_1_2 %>% filter(COD %in% c("41020101", "410202", "410203", "41020801", "41020901"))
  ingresos_rc_niif_1_2$niif <- ingresos_rc_niif_1_2$GRUPO
  
  ingresos_rc_rcp_6_7_8 <- base %>% dplyr::filter(GRUPO %in% c(6,7,8))
  ingresos_rc_rcp_6_7_8 <- ingresos_rc_rcp_6_7_8 %>% filter(COD %in% c("431101", "431102", "431122", "431103", "431104")) 
  ingresos_rc_rcp_6_7_8$niif <- ingresos_rc_rcp_6_7_8$GRUPO
  
  ingresos_rc <- rbind(ingresos_rc_niif_1_2,ingresos_rc_rcp_6_7_8)
  rm(ingresos_rc_niif_1_2,ingresos_rc_rcp_6_7_8)
  
  ingresos_rc$Regimen <- "Contributivo"
  
  ingresos_rc$Periodo <- i
  
  ingresos_rc <- left_join(ingresos_rc, Ingresos_Codigos) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))

  # Costs ####
  
  costos_rc_niif_1_2 <- base %>% dplyr::filter(GRUPO %in% c(1,2))
  costos_rc_niif_1_2 <- costos_rc_niif_1_2 %>% filter(COD %in% c("61020101", "61020301", "61020401", "61020601", "61021001", 
                                                                 "61021201", "61021301", "61021401", "61021501", "61050101"))
  costos_rc_niif_1_2$niif <- costos_rc_niif_1_2$GRUPO
  
  costos_rc_rcp_6_7_8 <- base %>% dplyr::filter(GRUPO %in% c(6,7,8))
  costos_rc_rcp_6_7_8$niif <- costos_rc_rcp_6_7_8$GRUPO
  
  if(i == "2021"){
    costos_rc_rcp_6_7_8 <- costos_rc_rcp_6_7_8 %>% filter(COD %in% c("561303", "561304", "561305"))
  }else{
    costos_rc_rcp_6_7_8 <- costos_rc_rcp_6_7_8 %>% filter(COD %in% c("561301", "561302", "561303", "561304", "561305"))
  }
  
  costos_rc_rcp_6_7_8$niif <- costos_rc_rcp_6_7_8$GRUPO
  
  costos_rc <- rbind(costos_rc_niif_1_2,costos_rc_rcp_6_7_8)
  rm(costos_rc_niif_1_2,costos_rc_rcp_6_7_8)
  
  costos_rc$Regimen <- "Contributivo"
  
  costos_rc$Periodo <- i
  
  costos_rc <- left_join(costos_rc, Costos_Codigos_Contributivo) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))
  
  ################################################################################
  ##############################  Subsidized regime   ##########################
  ################################################################################
  
  # Incomes ####
  
  ingresos_rs_niif_1_2 <- base %>% dplyr::filter(GRUPO %in% c(1,2))
  ingresos_rs_niif_1_2 <- ingresos_rs_niif_1_2 %>% filter(COD %in% c("41020102", "41020902"))
  ingresos_rs_niif_1_2$niif <- ingresos_rs_niif_1_2$GRUPO
  
  ingresos_rs_rsp_6_7_8 <- base %>% dplyr::filter(GRUPO %in% c(6,7,8))
  ingresos_rs_rsp_6_7_8 <- ingresos_rs_rsp_6_7_8 %>% filter(COD %in% c("431106", "431107")) 
  ingresos_rs_rsp_6_7_8$niif <- ingresos_rs_rsp_6_7_8$GRUPO
  
  ingresos_rs <- rbind(ingresos_rs_niif_1_2,ingresos_rs_rsp_6_7_8)
  rm(ingresos_rs_niif_1_2,ingresos_rs_rsp_6_7_8)
  
  ingresos_rs$Regimen <- "Subsidiado"
  
  ingresos_rs$Periodo <- i
  
  ingresos_rs <- left_join(ingresos_rs, Ingresos_Codigos) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))
  
  # Costs ####
  
  costos_rs_niif_1_2 <- base %>% dplyr::filter(GRUPO %in% c(1,2))
  costos_rs_niif_1_2 <- costos_rs_niif_1_2 %>% filter(COD %in% c("61020102", "61020302", "61020402", "61020602", "61021002", 
                                                                 "61021202", "61021302", "61021402", "61021502", "61050102"))
  costos_rs_niif_1_2$niif <- costos_rs_niif_1_2$GRUPO
  
  costos_rs_rsp_6_7_8 <- base %>% dplyr::filter(GRUPO %in% c(6,7,8))
  
  if(i == "2021"){
    costos_rs_rsp_6_7_8 <- costos_rs_rsp_6_7_8 %>% filter(COD %in% c("561309", "561310", "561311", "561390"))
  }else{
    costos_rs_rsp_6_7_8 <- costos_rs_rsp_6_7_8 %>% filter(COD %in% c("561307", "561308", "561309", "561310", "561311", "561390"))
  }
  
  costos_rs_rsp_6_7_8$niif <- costos_rs_rsp_6_7_8$GRUPO
  
  costos_rs <- rbind(costos_rs_niif_1_2,costos_rs_rsp_6_7_8)
  rm(costos_rs_niif_1_2,costos_rs_rsp_6_7_8)
  
  costos_rs$Regimen <- "Subsidiado"
  
  costos_rs$Periodo <- i
  
  costos_rs <- left_join(costos_rs, Costos_Codigos_Subsidiado) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))
  
  ingresos <- rbind(ingresos_rc, ingresos_rs)
  ingresos$Tipo <- "Ingresos"
  rm(ingresos_rc, ingresos_rs)
  
  costos <- rbind(costos_rc, costos_rs)
  costos$Tipo <- "Costos"
  rm(costos_rc, costos_rs)
  
  #------------------------------------------------------------------------------------
  #          Section 3. Calculation of technical reserves for PAR 6, 7 and 8
  #------------------------------------------------------------------------------------  
  
  reservas_tecnicas <- base %>% dplyr::filter(GRUPO %in% c(6,7,8))
  reservas_tecnicas$niif <- reservas_tecnicas$GRUPO
  
  if(i %in% c("2020", "2021")){
    reservas_tecnicas <- reservas_tecnicas %>% filter(COD %in% c("537201", "537202", "537290"))
  }else{
    reservas_tecnicas <- reservas_tecnicas %>% filter(COD %in% c("561320", "561321", "561323"))    
  }
  
  reservas_tecnicas$Regimen <- reservas_tecnicas$REGIMEN
  
  reservas_tecnicas$Periodo <- i
  
  reservas_tecnicas <- left_join(reservas_tecnicas, Costos_Codigos_Reservas) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))
  
  reservas_tecnicas$Tipo <- "Reservas técnicas"
  
  #------------------------------------------------------------------------------------
  #                     Section 4. Calculation of reserve release
  #------------------------------------------------------------------------------------  
  
  liberacion_niif_1_2 <- base %>% dplyr::filter(GRUPO %in% c(1,2))
  liberacion_niif_1_2 <- liberacion_niif_1_2 %>% filter(COD %in% c("410204", "410205", "410206"))
  liberacion_niif_1_2$niif <- liberacion_niif_1_2$GRUPO
  
  liberacion_niif_1_2$Regimen <- liberacion_niif_1_2$REGIMEN
  
  liberacion_niif_1_2$Periodo <- i
  
  liberacion_niif_1_2 <- left_join(liberacion_niif_1_2, Liberacion_Codigos) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))
  
  liberacion_niif_1_2_1 <- liberacion_niif_1_2 %>% 
    filter(Regimen != "CONTRIBUTIVO Y SUBSIDIADO")
  
  liberacion_niif_1_2_2 <- liberacion_niif_1_2 %>% 
    filter(Regimen == "CONTRIBUTIVO Y SUBSIDIADO") %>% 
    select(-Regimen)
  
  if(i == "2017"){
    liberacion_niif_1_2_2_Contributivo <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.04,
                                 ifelse(NIT == "900226715", 0.04,
                                        ifelse(NIT == "901097473", 0.7,
                                               ifelse(NIT == "900156264", 0.74,
                                                      ifelse(NIT == "830074184", 0.07, NA))))))
  }else if(i == "2018"){
    liberacion_niif_1_2_2_Contributivo <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.05,
                                 ifelse(NIT == "900226715", 0.05,
                                        ifelse(NIT == "901097473", 0.66,
                                               ifelse(NIT == "900156264", 0.72,
                                                      ifelse(NIT == "830074184", 0.08, NA))))))
  }else if(i == "2019"){
    liberacion_niif_1_2_2_Contributivo <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.07,
                                 ifelse(NIT == "900226715", 0.05,
                                        ifelse(NIT == "901097473", 0.59,
                                               ifelse(NIT == "900156264", 0.68,
                                                      ifelse(NIT == "830074184", 0.07, NA))))))
  }else if(i == "2020"){
    liberacion_niif_1_2_2_Contributivo <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.08,
                                 ifelse(NIT == "900226715", 0.07,
                                        ifelse(NIT == "901097473", 0.47,
                                               ifelse(NIT == "900156264", 0.58,
                                                      ifelse(NIT == "830074184", 0, NA))))))
  }else if(i == "2021"){
    liberacion_niif_1_2_2_Contributivo <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.08,
                                 ifelse(NIT == "900226715", 0.08,
                                        ifelse(NIT == "901097473", 0.42,
                                               ifelse(NIT == "900156264", 0.55,
                                                      ifelse(NIT == "830074184", 0, NA))))))
  }
  
  
  if(i == "2017"){
    liberacion_niif_1_2_2_Subsidiado <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.96,
                                 ifelse(NIT == "900226715", 0.96,
                                        ifelse(NIT == "901097473", 0.3,
                                               ifelse(NIT == "900156264", 0.26,
                                                      ifelse(NIT == "830074184", 0.93, NA))))))
  }else if(i == "2018"){
    liberacion_niif_1_2_2_Subsidiado <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.95,
                                 ifelse(NIT == "900226715", 0.95,
                                        ifelse(NIT == "901097473", 0.34,
                                               ifelse(NIT == "900156264", 0.28,
                                                      ifelse(NIT == "830074184", 0.92, NA))))))
  }else if(i == "2019"){
    liberacion_niif_1_2_2_Subsidiado <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.93,
                                 ifelse(NIT == "900226715", 0.95,
                                        ifelse(NIT == "901097473", 0.41,
                                               ifelse(NIT == "900156264", 0.32,
                                                      ifelse(NIT == "830074184", 0.93, NA))))))
  }else if(i == "2020"){
    liberacion_niif_1_2_2_Subsidiado <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.92,
                                 ifelse(NIT == "900226715", 0.93,
                                        ifelse(NIT == "901097473", 0.53,
                                               ifelse(NIT == "900156264", 0.42,
                                                      ifelse(NIT == "830074184", 0, NA))))))
  }else if(i == "2021"){
    liberacion_niif_1_2_2_Subsidiado <- liberacion_niif_1_2_2 %>% 
      mutate(Porcentaje = ifelse(NIT == "806008394", 0.92,
                                 ifelse(NIT == "900226715", 0.92,
                                        ifelse(NIT == "901097473", 0.58,
                                               ifelse(NIT == "900156264", 0.45,
                                                      ifelse(NIT == "830074184", 0, NA))))))
  }
  
  liberacion_niif_1_2_2_Subsidiado$Regimen <- "Subsidiado"
  liberacion_niif_1_2_2_Contributivo$Regimen <- "Contributivo"
  
  liberacion_niif_1_2_2_Subsidiado <- liberacion_niif_1_2_2_Subsidiado %>% 
    mutate(cost = cost*Porcentaje) %>% 
    select(-Porcentaje)
  
  liberacion_niif_1_2_2_Contributivo <- liberacion_niif_1_2_2_Contributivo %>% 
    mutate(cost = cost*Porcentaje) %>% 
    select(-Porcentaje)
  
  liberacion_niif_1_2_1 <- rbind(liberacion_niif_1_2_1, liberacion_niif_1_2_2_Contributivo, liberacion_niif_1_2_2_Subsidiado)
  
  liberacion_rpc_6_7_8 <- base %>% dplyr::filter(GRUPO %in% c(6,7,8))
  liberacion_rpc_6_7_8 <- liberacion_rpc_6_7_8 %>% filter(COD %in% c("435508"))
  liberacion_rpc_6_7_8$niif <- liberacion_rpc_6_7_8$GRUPO
  
  liberacion_rpc_6_7_8$Regimen <- liberacion_rpc_6_7_8$REGIMEN
  
  liberacion_rpc_6_7_8$Periodo <- i
  
  liberacion_rpc_6_7_8 <- left_join(liberacion_rpc_6_7_8, Liberacion_Codigos) %>% 
    select(c(COD, NIT, cost, NOMBRE, niif, Regimen, Cuenta))
  
  liberacion <- rbind(liberacion_niif_1_2_1, liberacion_rpc_6_7_8)
  liberacion$Tipo <- "Liberación"
  
  rm(liberacion_niif_1_2_1, liberacion_niif_1_2_2_Contributivo, liberacion_niif_1_2_2_Subsidiado, liberacion_rpc_6_7_8, liberacion_niif_1_2, liberacion_niif_1_2_2)
  
  
  #---------------------------------------------------------------------------------------------------
  #     Section 5. Unite the bases of income, costs, technical reserves and release of reserves
  #--------------------------------------------------------------------------------------------------- 

  base <- rbind(ingresos, costos)
  base <- rbind(base, reservas_tecnicas)
  base <- rbind(base, liberacion)
  
  base$Periodo <- i
  
  rm(ingresos, costos, reservas_tecnicas, liberacion)
  
  Consolidado <- rbind(Consolidado, base)
  
}

rm(Costos_Codigos_Contributivo, Costos_Codigos_Subsidiado, Costos_Codigos_Reservas, Ingresos_Codigos, Liberacion_Codigos, base)

#------------------------------------------------------------------------------------
#                     Section 6. Calculation of loss ratio
#------------------------------------------------------------------------------------ 

Consolidado$Regimen[Consolidado$Regimen == "CONTRIBUTIVO"] <- "Contributivo"
Consolidado$Regimen[Consolidado$Regimen == "SUBSIDIADO"] <- "Subsidiado"

Consolidado <- Consolidado %>% 
  mutate(Nombres_Consolidados = ifelse((Cuenta == "Contratos de capitación – Contributivo" | Cuenta == "Contratos de capitación – Subsidiado"), "Contratos de capitación", 
                                       ifelse((Cuenta == "Contratos por evento y otras modalidades – Contributivo" | Cuenta == "Contratos por evento y otras modalidades – Subsidiado" ), "Contratos por evento y otras modalidades",
                                              ifelse((Cuenta == "Costo reservas técnicas - Liquidadas pendientes de pago - Servicio de salud" | Cuenta == "Costo reservas técnicas - Liquidadas pendientes de pago – Servicios de salud" ), "Costo reservas técnicas - Liquidadas pendientes de pago - Servicio de salud",
                                                     ifelse((Cuenta == "Contratos por evento y otras modalidades – Contributivo" | Cuenta == "Contratos por evento y otras modalidades – Subsidiado"), "Contratos por evento y otras modalidades",
                                                            ifelse((Cuenta == "Costo reserva técnica - Pendientes no conocida - Servicios de salud" | Cuenta == "Costo reservas técnicas - Pendientes no conocidas - Servicios de salud" ), "Costo reservas técnicas - Pendientes no conocidas - Servicios de salud",
                                                                   ifelse((Cuenta == "Costo reservas técnicas - Conocidos no liquidados - Servicios de salud" | Cuenta == "Costo reservas técnicas - Conocidos no liquidados - Servicios de salud" ), "Costo reservas técnicas - Conocidos no liquidados - Servicios de salud",
                                                                          ifelse((Cuenta == "Costo reservas técnicas - Liquidadas pendientes de pago - Servicio de salud" | Cuenta == "Costo reservas técnicas - Liquidadas pendientes de pago – Servicios de salud" ), "Costo reservas técnicas - Liquidadas pendientes de pago - Servicio de salud",
                                                                                 ifelse((Cuenta == "Otras reservas" | Cuenta == "Otras Reservas" ), "Otras reservas",
                                                                                        ifelse((Cuenta == "Promoción y prevención – Contributivo" | Cuenta == "Promoción y prevención – Subsidiado" ), "Promoción y prevención",
                                                                                               ifelse((Cuenta == "Reaseguro enfermedades de alto costo – Contributivo" | Cuenta == "Reaseguro enfermedades de alto costo – Subsidiado" ), "Reaseguro enfermedades de alto costo",
                                                                                                      ifelse((Cuenta == "Sistema de garantía y calidad – Subsidiado" | Cuenta == "Sistema de garantía y calidad – Contributivo" ), "Sistema de garantía y calidad", 
                                                                                                             ifelse((Cuenta == "Reservas técnicas por servicios de salud ocurridos no conocidos" | Cuenta == "Reserva  técnica  por  servicios  y  tecnologías  en  salud  ocurridos  no  conocidos"), "Reservas técnicas por servicios de salud ocurridos no conocidos",
                                                                                                                    ifelse((Cuenta == "Otras provisiones para servicios y tecnologías en salud" | Cuenta == "Otras provisiones para servicios de salud" | Cuenta == "Otras reservas técnicas"), "Otras reservas técnicas", Cuenta)))))))))))))) %>% 
  filter(cost != 0) %>% 
  mutate(Factor_ajuste = ifelse(Periodo == 2017, 1.15,
                                ifelse(Periodo == 2018, 1.11,
                                       ifelse(Periodo == 2019, 1.07,
                                              ifelse(Periodo == 2020, 1.06, 1)))),
         Monto_Deflactado = cost * Factor_ajuste) %>% 
  rename(Monto = cost) %>% 
  select(-Factor_ajuste)

Participacion_Cuentas <- Consolidado %>% 
  group_by(Tipo, Nombres_Consolidados, COD, niif, Periodo) %>% 
  summarise(Monto = sum(Monto),
            Monto_Deflactado = sum(Monto_Deflactado))

Siniestralidad_Regimen <- Consolidado %>% 
  group_by(Periodo, Regimen, Tipo) %>% 
  summarise(Monto = sum(Monto))

Siniestralidad_Total <- Consolidado %>% 
  group_by(Periodo, Tipo) %>% 
  summarise(Monto = sum(Monto))

Siniestralidad_Total$Regimen <- "SGSSS"

Siniestralidad <- rbind(Siniestralidad_Regimen, Siniestralidad_Total)
rm(Siniestralidad_Regimen, Siniestralidad_Total)

Siniestralidad <- spread(Siniestralidad, Tipo, Monto)

Siniestralidad[is.na(Siniestralidad)] <- 0

Siniestralidad <- Siniestralidad %>% 
  mutate(IS = (Costos + `Reservas técnicas` - Liberación)/Ingresos)
  
Siniestralidad_EPS <- Consolidado %>% 
  group_by(NIT, NOMBRE, Tipo, Periodo) %>% 
  summarise(Monto = sum(Monto))

Siniestralidad_EPS <- spread(Siniestralidad_EPS, Tipo, Monto)

Siniestralidad_EPS[is.na(Siniestralidad_EPS)] <- 0

Siniestralidad_EPS <- Siniestralidad_EPS %>% 
  mutate(IS = (Costos + `Reservas técnicas` - Liberación)/Ingresos)

Siniestralidad_Clasificacion <-  Consolidado %>% 
  group_by(niif, Tipo, Periodo) %>% 
  summarise(Monto = sum(Monto))

Siniestralidad_Clasificacion <- spread(Siniestralidad_Clasificacion, Tipo, Monto)

Siniestralidad_Clasificacion[is.na(Siniestralidad_Clasificacion)] <- 0

Siniestralidad_Clasificacion <- Siniestralidad_Clasificacion %>% 
  mutate(IS = (Costos + `Reservas técnicas` - Liberación)/Ingresos)

# Export to excel
OUT <- createWorkbook()

addWorksheet(OUT, "Cuentas")
addWorksheet(OUT, "Siniestralidad Total")
addWorksheet(OUT, "Siniestralidad EPS")
addWorksheet(OUT, "Siniestralidad NIIF")

writeData(OUT, sheet = "Cuentas", x = Participacion_Cuentas)
writeData(OUT, sheet = "Siniestralidad Total", x = Siniestralidad)
writeData(OUT, sheet = "Siniestralidad EPS", x = Siniestralidad_EPS)
writeData(OUT, sheet = "Siniestralidad NIIF", x = Siniestralidad_Clasificacion)

saveWorkbook(OUT, "./Datos/Salidas/Consolidado_UPC.xlsx")


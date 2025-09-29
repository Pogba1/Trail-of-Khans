function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para reclutar las unidades necesarias
    if country:GetResource("manpower") >= 1500 and country:GetResource("money") >= 3000 then
        -- Verifica si el país está siendo justificado o tiene objetivo de guerra
        if country:IsBeingJustified() or country:HasWarGoal() then
            country:Mobilize()
        end
        
        -- Función para crear brigadas profesionales según el tipo de unidad y la cantidad requerida
        local function createBrigades(unitType, requiredBrigades)
            local currentBrigades = army:GetNumberOfRegimentsOfType(unitType)
            local brigadesToCreate = requiredBrigades - currentBrigades
            
            if brigadesToCreate > 0 then
                local unitsToCreate = brigadesToCreate * 30
                
                -- Verificar si el país es civilizado para crear brigadas profesionales
                if country:IsCivilized() then
        for i = 1, infantryBrigadesToCreate do
            country:BuildProfessionalRegiment("infantry")
        end
        for i = 1, cuirassierBrigadesToCreate do
            country:BuildProfessionalRegiment("cuirassier")
        end
        for i = 1, artilleryBrigadesToCreate do
            country:BuildProfessionalRegiment("artillery")
        end
    else
                    -- Crear brigadas normales para países incivilizados
                    for i = 1, brigadesToCreate do
                        country:BuildRegiment(unitType)
                    end
                end
                
                -- Dividir el ejército en las brigadas recién creadas
                country:SplitArmy(army, unitType, unitsToCreate)
            end
        end

        -- Crea brigadas de infantería
        createBrigades("infantry", 4)

        -- Crea brigadas de caballería
        createBrigades("cuirassier", 1)

        -- Crea brigadas de artillería
        createBrigades("artillery", 5)

        -- Mover ejército a provincias aleatorias para proteger las fronteras
        local provinces = country:GetProvinces()
        local borderProvinces = {}
        for i = 1, #provinces do
            local province = provinces[i]
            if province:IsAdjacentToEnemy() then
                table.insert(borderProvinces, province)
            end
        end

        if #borderProvinces > 0 then
            -- Si hay provincias fronterizas, mueve el ejército a una de ellas
            local randomProvinceIndex = math.random(1, #borderProvinces)
            local targetProvince = borderProvinces[randomProvinceIndex]
            country:MoveArmy(army, targetProvince:GetPosition())
        else
            -- Si no hay provincias fronterizas, mueve el ejército a una provincia aleatoria
            local randomProvinceIndex = math.random(1, #provinces)
            local targetProvince = provinces[randomProvinceIndex]
            country:MoveArmy(army, targetProvince:GetPosition())
        end
    end
end


function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para construir fábricas
    if country:GetResource("money") >= 5000 then
        -- Lista de todos los recursos que pueden ser producidos en fábricas
        local allResources = {
            "cattle", "fish", "grain", "fruit", "coal", "iron", "wood", "sulfur", "rubber",
            "oil", "cotton", "wool", "precious_metal", "cocoa", "tea", "tobacco", "dye",
            "silk", "copper", "lead", "timber", "coffee", "sulphur", "opium", "tropical_wood",
            "tropical_wood_1", "tropical_wood_2", "tropical_wood_3", "tropical_wood_4",
            "tropical_wood_5", "tropical_wood_6", "tropical_wood_7", "tropical_wood_8",
            "tropical_wood_9", "tropical_wood_10", "tropical_wood_11", "tropical_wood_12",
            "tropical_wood_13", "tropical_wood_14", "tropical_wood_15", "tropical_wood_16",
            "tropical_wood_17", "tropical_wood_18", "tropical_wood_19", "tropical_wood_20"
        }

        -- Construye fábricas para los recursos faltantes
        for i = 1, #allResources do
            local resource = allResources[i]
            if country:GetResource(resource) <= 0 then
                country:BuildFactory(resource)
            end
        end

        -- Mejora las fábricas existentes
        local factories = country:GetFactories()
        for i = 1, #factories do
            local factory = factories[i]
            -- Si la fábrica no está en construcción y hay suficiente dinero, mejórala
            if not factory:IsBuilding() and country:GetResource("money") >= 5000 then
                factory:Improve()
            end
        end
    end

    -- Reduce el stockpile si es necesario
    local stockpileThreshold = 1000
    for i = 1, #allResources do
        local resource = allResources[i]
        local stockpile = country:GetResource(resource .. "_stockpile")
        if stockpile > stockpileThreshold then
            country:SetResource(resource .. "_stockpile", stockpile - stockpileThreshold)
        end
    end
end

function OnProvinceCaptured(province)
    -- No destruir fábricas al capturar provincias
end


function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para construir barcos
    if country:GetResource("money") >= 5000 then
        -- Construye barcos de transporte si no hay suficientes
        local transportShipsNeeded = 10
        local transportShips = country:GetNumberOfShips("transport_ship")
        if transportShips < transportShipsNeeded then
            for i = 1, transportShipsNeeded - transportShips do
                country:BuildShip("transport_ship")
            end
        end

        -- Construye barcos de guerra si no hay suficientes
        local warShipsNeeded = 5
        local warShips = country:GetNumberOfShips("war_ship")
        if warShips < warShipsNeeded then
            for i = 1, warShipsNeeded - warShips do
                country:BuildShip("war_ship")
            end
        end

        -- Obtiene una lista de provincias costeras
        local coastalProvinces = country:GetCoastalProvinces()

        -- Selecciona una provincia costera aleatoria para realizar el desembarco
        local randomProvinceIndex = math.random(1, #coastalProvinces)
        local targetProvince = coastalProvinces[randomProvinceIndex]

        -- Mueve los barcos a la provincia seleccionada
        local transportShips = country:GetShips("transport_ship")
        for i = 1, #transportShips do
            local ship = transportShips[i]
            country:MoveShip(ship, targetProvince:GetPosition())
        end

        -- Mueve los barcos de guerra a la misma provincia
        local warShips = country:GetShips("war_ship")
        for i = 1, #warShips do
            local ship = warShips[i]
            country:MoveShip(ship, targetProvince:GetPosition())
        end
    end
end

function CountryAI_Tick(country)
    -- Verifica si el país tiene suficientes recursos para construir fortalezas y raíles
    if country:GetResource("money") >= 5000 then
        -- Construye fortalezas en las fronteras y provincias importantes si no hay suficientes
        local importantProvinces = country:GetImportantProvinces()
        for province in importantProvinces do
            if not province:HasFort() then
                country:BuildFort(province)
            end
        end

        -- Espera un tiempo antes de mejorar las fortalezas
        local fortUpgradeTime = 30 -- Espera 30 días antes de mejorar las fortalezas
        if country:GetDaysSinceLastFortUpgrade() >= fortUpgradeTime then
            local forts = country:GetForts()
            for i = 1, #forts do
                local fort = forts[i]
                if fort:GetLevel() < 5 then -- Mejora la fortaleza hasta el nivel máximo
                    fort:Upgrade()
                end
            end
        end

        -- Construye lentamente fortalezas y raíles en la capital
        local capital = country:GetCapital()
        if not capital:HasFort() then
            country:BuildFort(capital)
        elseif not capital:HasRailroad() then
            country:BuildRailroad(capital)
        end
    end

    -- Reduce el stockpile si es necesario
    local stockpileThreshold = 1000
    local allResources = country:GetAllResources()
    for i = 1, #allResources do
        local resource = allResources[i]
        local stockpile = country:GetResource(resource .. "_stockpile")
        if stockpile > stockpileThreshold then
            country:SetResource(resource .. "_stockpile", stockpile - stockpileThreshold)
        end
    end
end

function CountryAI_ManageEconomy(country)
    -- Verifica si la economía está en rojo
    if country:GetResource("money") < 0 then
        -- Cambia al gobierno que maximiza la capacidad de construcción de fábricas
        country:ChangeGovernment("interventionism")

        -- Aumenta los impuestos al máximo
        country:SetTaxRate(100)

        -- Reduce el gasto militar y de construcción
        country:SetMilitarySpending(50)
        country:SetConstructionSpending(50)
    end

    -- Verifica si la economía está en verde
    if country:GetResource("money") >= 0 then
        -- Aumenta el gasto militar y de construcción a la mitad
        country:SetMilitarySpending(100)
        country:SetConstructionSpending(100)

        -- Redefine los impuestos y las tarifas para mantener la economía en verde
        local profitMargin = 5000 -- Margen de ganancia deseado
        local money = country:GetResource("money")
        local taxRate = country:GetTaxRate()
        local tariff = country:GetTariff()

        while money < profitMargin do
            if money < 0 then
                -- Aumenta las tarifas
                country:SetTariff(tariff + 1)
            else
                -- Reduce los impuestos
                country:SetTaxRate(taxRate - 1)
            end
            money = country:GetResource("money")
        end
    end
end

function CountryAI_RushFormablesAndDecisions(country)
    -- Verifica si hay formables disponibles
    local formables = country:GetAvailableFormables()
    for i = 1, #formables do
        local formable = formables[i]
        -- Verifica si el formable está disponible para ser completado
        if country:CanCompleteFormable(formable) then
            country:CompleteFormable(formable)
        end
    end

    -- Verifica si hay decisiones disponibles
    local decisions = country:GetAvailableDecisions()
    for i = 1, #decisions do
        local decision = decisions[i]
        -- Verifica si la decisión está disponible para ser tomada
        if country:CanTakeDecision(decision) then
            country:TakeDecision(decision)
        end
    end

    -- Espera a los requisitos necesarios para los formables y decisiones
    local requiredStates = {
        "Moscow", "Saint Petersburg" -- Agrega aquí los nombres de los estados necesarios
    }
    for i = 1, #requiredStates do
        local stateName = requiredStates[i]
        local state = country:GetState(stateName)
        if not state:IsOwnedBy(country) then
            country:RequestStateOwnership(state)
        end
    end
end

function CountryAI_ManageExpansion(country)
    -- Verifica si hay guerras en curso
    local wars = country:GetCurrentWars()
    for i = 1, #wars do
        local war = wars[i]
        local warScore = war:GetWarScore(country)

        -- Verifica si el warscore supera el 100%
        if warScore >= 100 then
            return
        end

        -- Verifica si la infamia supera el límite
        local infamy = country:GetInfamy()
        if infamy >= 25 then -- Ajusta el límite de infamia según sea necesario
            return
        end

        -- Verifica el tipo de guerra
        local warGoal = war:GetWarGoal()

        -- Si el objetivo de guerra es anexión o conquista, intenta tomar provincias vecinas
        if warGoal == "annexation" or warGoal == "conquest" then
            local targetProvinces = country:GetAvailableProvincesToTake(war)
            for j = 1, #targetProvinces do
                local province = targetProvinces[j]
                -- Verifica si la provincia es vecina y no es ocupada por otro país
                if province:IsNeighbouringTo(country) and not province:IsOccupied() then
                    -- Toma la provincia si es posible
                    country:TakeProvince(province)
                end
            end
        end

        -- Gestiona la diplomacia durante la guerra según el tipo de guerra
        if warGoal == "humiliation" then
            -- Humillar al enemigo si tiene sentido
            -- country:HumiliateEnemy(war:GetEnemy())
        elseif warGoal == "sphere" then
            -- Esferar al enemigo si tiene sentido
            -- country:AddToSphere(war:GetEnemy())
        end
    end
end

function CountryAI_HandleCrisis(country, crisis)
    -- Verifica si el jugador está involucrado en la crisis
    local playerInvolved = false
    local participants = crisis:GetParticipants()
    for i = 1, #participants do
        if participants[i] == country then
            playerInvolved = true
            break
        end
    end

    -- Si el jugador no está involucrado, rechaza las propuestas de unirse a la crisis
    if not playerInvolved then
        crisis:RejectProposal(country)
        return
    end

    -- Si el jugador está involucrado, no traicionar al jugador durante la crisis
    local player = GetPlayerCountry() -- Suponiendo que hay una función para obtener el país del jugador
    if crisis:IsWar() and crisis:GetAggressor() == player then
        -- Si la crisis es una guerra y el jugador es el agresor, no traicionar al jugador
        crisis:RejectProposal(country)
    elseif crisis:IsMediation() and crisis:GetMediator() == player then
        -- Si la crisis es una mediación y el jugador es el mediador, no traicionar al jugador
        crisis:RejectProposal(country)
    elseif crisis:IsUltimatum() and crisis:GetTarget() == player then
        -- Si la crisis es un ultimátum y el jugador es el objetivo, no traicionar al jugador
        crisis:RejectProposal(country)
    end
end

function CountryAI_ResearchTechnology(country)
    -- Prioridades de investigación
    local researchPriorities = {
        "chemistry_and_electricity", -- Química y Electricidad
        "military", -- Tecnologías militares
        "political_thought", -- Estado y Gobierno (Línea de Political Thought)
        "industry", -- Industria
        "random" -- Si todas las categorías anteriores están llenas, investiga una tecnología aleatoria
    }

    -- Si el país es incivilizado, prioriza las reformas que otorgan puntos por conquistar estados
    if country:IsUncivilized() then
        local availableReforms = country:GetAvailableReforms()
        for i = 1, #availableReforms do
            local reform = availableReforms[i]
            if reform:GivesPointsForConquering() then
                country:PassReform(reform)
                return
            end
        end
    end

    -- Busca la próxima tecnología disponible según las prioridades definidas
    for i = 1, #researchPriorities do
        local priority = researchPriorities[i]
        local nextTech = country:GetNextAvailableTechnology(priority)
        if nextTech then
            country:ResearchTechnology(nextTech)
            return
        end
    end
end

function CountryAI_PrioritizeFocus(country)
    -- Prioriza la creación de focos militares hasta alcanzar 5
    local militaryFocusCount = 0
    while militaryFocusCount < 5 do
        local provinces = country:GetProvinces()
        local lowestMilitaryFocusProvince
        local lowestMilitaryFocus = 1
        for i = 1, #provinces do
            local province = provinces[i]
            local militaryFocus = province:GetPops("soldiers"):GetFocus()
            if militaryFocus < lowestMilitaryFocus then
                lowestMilitaryFocusProvince = province
                lowestMilitaryFocus = militaryFocus
            end
        end
        if lowestMilitaryFocusProvince then
            country:ChangeFocus(lowestMilitaryFocusProvince, "soldiers")
            militaryFocusCount = militaryFocusCount + 1
        else
            break
        end
    end

    -- Si es incivilizado, también prioriza la creación de focos intelectuales
    if country:IsUncivilized() then
        local intellectualFocusCount = 0
        while intellectualFocusCount < 5 do
            local provinces = country:GetProvinces()
            local lowestIntellectualFocusProvince
            local lowestIntellectualFocus = 1
            for i = 1, #provinces do
                local province = provinces[i]
                local intellectualFocus = province:GetPops("clergymen"):GetFocus()
                if intellectualFocus < lowestIntellectualFocus then
                    lowestIntellectualFocusProvince = province
                    lowestIntellectualFocus = intellectualFocus
                end
            end
            if lowestIntellectualFocusProvince then
                country:ChangeFocus(lowestIntellectualFocusProvince, "clergymen")
                intellectualFocusCount = intellectualFocusCount + 1
            else
                break
            end
        end
    end
end
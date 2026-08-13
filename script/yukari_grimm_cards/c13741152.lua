--Vicious Theatre Alice of Looking-Glassland
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	Pendulum.AddProcedure(c)
	--You can destroy this card, then place 2 face-up non-Beast-Warrior "Vicious Theatre" Pendulum Monsters from your Extra Deck, Deck and/or GY in your Pendulum Zone
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	e0:SetValue(s.zones)
	c:RegisterEffect(e0)
	--Can be treated as Level 4 or 6 for a "Vicious Theatre" Xyz
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.xyzlv)
	c:RegisterEffect(e1)	
	--Add 1 (face-up or face-down) "Vicious Theatre" Trap from your Deck, GY or banishment to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thttg)
	e2:SetOperation(s.thtop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)	
	
end

s.listed_series={0x41e}
s.listed_names={id}

function s.plfilter(c)
	return not c:IsRace(RACE_BEASTWARRIOR) and c:IsSetCard(0x41e) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) and Duel.CheckPendulumZones(tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TOFIELD)
	if #tg==0 then return end
		for tc in tg:Iter() do	
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end

function s.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff --all S/T zones
	local left_pend=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	local right_pend=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	if left_pend and right_pend then
		return zone
	elseif left_pend then
		--Remove the left-most Spell & Trap Zone
		zone=zone-0x1
	elseif right_pend then
		--Remove the right-most Spell & Trap Zone
		zone=zone-0x10
	end
	return zone
end

function s.xyzlv(e,c,rc)
	if rc:IsSetCard(0x41e) then
		return 4,6,e:GetHandler():GetLevel()
	else
		return e:GetHandler():GetLevel()
	end
end

function s.thtfilter(c)
	return (c:IsFacedown() or c:IsFaceup()) and c:IsSetCard(0x41e) and c:IsTrap() and c:IsAbleToHand()
end

function s.thttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thtfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thtfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
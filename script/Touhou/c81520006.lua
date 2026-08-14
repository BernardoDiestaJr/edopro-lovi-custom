--Windrous Miracle "Divine Welcoming"
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card as a Normal Monster (Spellcaster/WIND/Level 4/ATK 1800/DEF 0) (this card is NOT treated as a Trap), then you can Special Summon 1 "Windrous Token" (Fairy/Tuner/WIND/Level 1/ATK 0/DEF 0)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
	e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	e0:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)	
	--You can activate this card the turn it was Set, by revealing 1 "Windrous Divitant Yasaka no Mikoto" or 1 "Windrous Divitant Moriya no Okami" in your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetValue(function(e) e:SetLabel(1) end)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.extracostfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,nil) end)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	--This card's name becomes "Sanae the Green Fantasia Priestess" while in the Monster Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(81519989)
	c:RegisterEffect(e2)	
	--Place 2 of your Synchro "Windrous" monsters from your Extra Deck in your Spell & Trap Zone as face-up Continuous Spells
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)	
	
end

s.listed_series={0x2f1}
s.listed_names={id,81519989,81520000,81520004,81520005}

function s.extracostfilter(c)
	return (c:IsCode(81520004) or c:IsCode(81520005)) and not c:IsPublic()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.extracostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2f1,TYPE_MONSTER|TYPE_NORMAL,1800,0,4,RACE_SPELLCASTER,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2f1,TYPE_MONSTER|TYPE_NORMAL,1800,0,4,RACE_SPELLCASTER,ATTRIBUTE_WIND) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		c:AddMonsterAttributeComplete()
		if Duel.SpecialSummonComplete()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,81520000,0x2f1,TYPES_TOKEN+TYPE_TUNER,0,0,1,RACE_FAIRY,ATTRIBUTE_WIND)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local token=Duel.CreateToken(tp,81520000)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.plfilter(c)
	return c:IsSetCard(0x2f1) and c:IsMonster() and c:IsType(TYPE_SYNCHRO) and not c:IsForbidden()
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return ft>1 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_EXTRA,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOFIELD)
	if #tg==0 then return end
	local c=e:GetHandler()
	for tc in tg:Iter() do	
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			--Treated as Continuous Spells
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
			tc:RegisterEffect(e1)
		end	
	end
end

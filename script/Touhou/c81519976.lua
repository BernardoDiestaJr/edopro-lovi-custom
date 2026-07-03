--Divine Implement - Aunn
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Special Summon token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- Field Spell protection
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTarget(s.reptg)
	e4:SetCountLimit(1,id)
	e4:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e4:SetOperation(function(e) Duel.SendtoDeck(e:GetHandler(),LOCATION_FZONE,SEQ_DECKSHUFFLE,REASON_EFFECT) end)
	c:RegisterEffect(e4)	
end

s.listed_names={id,0x1f9,81519980}
s.listed_series={0x1f9}

function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1f9)
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsLocation(LOCATION_FZONE)
end

function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,81519980,nil,TYPES_TOKEN,900,1800,2,RACE_BEAST,ATTRIBUTE_EARTH)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local c=e:GetHandler()
		local token=Duel.CreateToken(tp,81519980)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		--Cannot Special Summon non-Link monsters from Extra Deck
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		--Lizard check
		local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not c:IsOriginalType(TYPE_LINK) end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end

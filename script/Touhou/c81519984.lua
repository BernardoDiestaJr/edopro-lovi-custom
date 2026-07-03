--Shinki of Pandaemonium
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 Illusion or LIGHT Fiend monsters + 1 LIGHT or DARK Spellcaster monster
	Fusion.AddProcMix(c,true,true,s.matfilter1,1,s.matfilter2,2)
	c:AddMustBeFusionSummoned()
	--You can only Fusion Summon or Special Summon by its alternate procedure "Shinki of Pandaemonium" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--You can Special Summon this card by banishing 1 Level 10 or higher DARK Illusion monster you control or in your GY as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	e1:SetValue(1)
	c:RegisterEffect(e1)	
	--Add 1 "Pandaemonium" or 1 card that mentions it from your Deck to your hand except itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Destroy 1 card you control and 1 card your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED) end)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)	
end	
	
s.listed_names={id,0x1f8}
s.listed_series={0x1fb}

function s.matfilter1(c,fc,sumtype,tp)
	return (c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)) and c:IsRace(RACE_SPELLCASTER,fc,sumtype,tp)
end

function s.matfilter2(c,fc,sumtype,tp)
	return (c:IsRace(RACE_ILLUSION,fc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_LIGHT,fc,sumtype,tp) and c:IsRace(RACE_FIEND,fc,sumtype,tp))
end

function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent another Fusion Summon or Special Summon by its alternate procedure of "Shinki of Pandaemonium" that turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.selfspcostfilter(c,tp,sc)
	return c:IsLevelAbove(10) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ILLUSION)
		and c:IsAbleToRemoveAsCost() and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end

function s.selfspcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.selfspcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp,c)
end

function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.selfspcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,true,nil,tp,c)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end

function s.thfilter(c)
	return (c:IsCode(0x1fb) or c:ListsCode(0x1fb)) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==1
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,2,tp,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
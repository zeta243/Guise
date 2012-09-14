package guise.controls.logic.input;
import composure.traits.AbstractTrait;
import guise.controls.ControlLayers;
import guise.controls.data.ITextLabel;
import guise.platform.IPlatformAccess;
import guise.platform.PlatformAccessor;
import guise.platform.types.TextAccessTypes;
import guise.controls.data.IInputPrompt;

/**
 * ...
 * @author Tom Byrne
 */

class TextInputPrompt extends AbstractTrait
{
	@inject
	public var textLabel(default, set_textLabel):ITextLabel;
	private function set_textLabel(value:ITextLabel):ITextLabel {
		this.textLabel = value;
		if (_showingPrompt && textLabel!=null) {
			if(inputPrompt!=null)textLabel.set(inputPrompt.prompt);
		}
		return value;
	}
	
	@inject
	public var inputPrompt(default, set_inputPrompt):IInputPrompt;
	private function set_inputPrompt(inputPrompt:IInputPrompt):IInputPrompt {
		if (inputPrompt != null) {
			inputPrompt.promptChanged.remove(onPromptChanged);
		}
		this.inputPrompt = inputPrompt;
		if (inputPrompt != null) {
			inputPrompt.promptChanged.add(onPromptChanged);
			onPromptChanged(inputPrompt);
		}
		return inputPrompt;
	}
	
	private var _input:ITextInputAccess;
	private var _focus:IFocusableAccess;
	private var _showingPrompt:Bool;
	private var _ignoreChanges:Bool;
	private var _focused:Bool;

	public function new(){
		super();
		
		addSiblingTrait(new PlatformAccessor(ITextInputAccess, ControlLayers.INPUT_TEXT, onInputAdd, onInputRemove));
		addSiblingTrait(new PlatformAccessor(IFocusableAccess, ControlLayers.INPUT_TEXT, onFocusAdd, onFocusRemove));
	}
	
	private function onInputAdd(access:ITextInputAccess):Void {
		_input = access;
		access.inputEnabled = true;
		access.textChanged.add(onTextChanged);
		onTextChanged(access);
	}
	private function onInputRemove(access:ITextInputAccess):Void {
		access.textChanged.remove(onTextChanged);
		_input = null;
	}
	private function onFocusAdd(access:IFocusableAccess):Void {
		_focus = access;
		access.focusedChanged.add(onFocusedChanged);
		onFocusedChanged(access);
	}
	private function onFocusRemove(access:IFocusableAccess):Void {
		access.focusedChanged.remove(onFocusedChanged);
		_focus = null;
	}
	private function onTextChanged(from:ITextInputAccess):Void {
		var text:String = from.getText();
		if(textLabel!=null)textLabel.set(text);
		if (!_focused && (text == null || text.length == 0)) {
			if(inputPrompt!=null)textLabel.set(inputPrompt.prompt);
			_showingPrompt = true;
		}
	}
	
	private function onPromptChanged(from:IInputPrompt):Void {
		var prompt:String = from.prompt;
		if (_showingPrompt && textLabel!=null) {
			textLabel.set(prompt);
		}
	}
	private function onFocusedChanged(from:IFocusableAccess):Void {
		_focused = from.focused;
		if(_focused){
			if (_showingPrompt) {
				textLabel.set("");
				_showingPrompt = false;
			}
		}else {
			if (!_showingPrompt && (textLabel==null || textLabel.text=="")) {
				if(inputPrompt!=null)textLabel.set(inputPrompt.prompt);
				_showingPrompt = true;
			}
		}
	}
}
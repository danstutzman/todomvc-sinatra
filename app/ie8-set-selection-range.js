if (!HTMLInputElement.prototype.setSelectionRange) {
    HTMLInputElement.prototype.setSelectionRange = function(start, end) {
        if (this.createTextRange) {
            var range = this.createTextRange();
            range.collapse(true);
            range.moveEnd('character', start);
            range.moveStart('character', end);
            range.select();
        }
    }
}

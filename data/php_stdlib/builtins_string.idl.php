<?php
// THIS IS AUTOGENERATED BY builtins_php.ml
function addcslashes($str, $charlist) { }
function stripcslashes($str) { }
function addslashes($str) { }
function stripslashes($str) { }
function bin2hex($str) { }
function hex2bin($str) { }
function nl2br($str) { }
function quotemeta($str) { }
function str_shuffle($str) { }
function strrev($str) { }
function strtolower($str) { }
function strtoupper($str) { }
function ucfirst($str) { }
function ucwords($str) { }
function strip_tags($str, $allowable_tags = "") { }
function trim($str, $charlist = k_HPHP_TRIM_CHARLIST) { }
function ltrim($str, $charlist = k_HPHP_TRIM_CHARLIST) { }
function rtrim($str, $charlist = k_HPHP_TRIM_CHARLIST) { }
function chop($str, $charlist = k_HPHP_TRIM_CHARLIST) { }
function explode($delimiter, $str, $limit = 0x7FFFFFFF) { }
function implode($arg1, $arg2 = null_variant) { }
function join($glue, $pieces = null_variant) { }
function str_split($str, $split_length = 1) { }
function chunk_split($body, $chunklen = 76, $end = "\r\n") { }
function strtok($str, $token = null_variant) { }
function str_replace($search, $replace, $subject, &$count = null) { }
function str_ireplace($search, $replace, $subject, &$count = null) { }
function substr_replace($str, $replacement, $start, $length = 0x7FFFFFFF) { }
function substr($str, $start, $length = 0x7FFFFFFF) { }
function str_pad($input, $pad_length, $pad_string = " ", $pad_type = k_STR_PAD_RIGHT) { }
function str_repeat($input, $multiplier) { }
function wordwrap($str, $width = 75, $wordbreak = "\n", $cut = false) { }
function html_entity_decode($str, $quote_style = k_ENT_COMPAT, $charset = "ISO-8859-1") { }
function htmlentities($str, $quote_style = k_ENT_COMPAT, $charset = "ISO-8859-1", $double_encode = true) { }
function htmlspecialchars_decode($str, $quote_style = k_ENT_COMPAT) { }
function htmlspecialchars($str, $quote_style = k_ENT_COMPAT, $charset = "ISO-8859-1", $double_encode = true) { }
function quoted_printable_encode($str) { }
function quoted_printable_decode($str) { }
function convert_uudecode($data) { }
function convert_uuencode($data) { }
function str_rot13($str) { }
function crc32($str) { }
function crypt($str, $salt = "") { }
function md5($str, $raw_output = false) { }
function sha1($str, $raw_output = false) { }
function strtr($str, $from, $to = null_variant) { }
function convert_cyr_string($str, $from, $to) { }
function get_html_translation_table($table = 0, $quote_style = k_ENT_COMPAT) { }
function hebrev($hebrew_text, $max_chars_per_line = 0) { }
function hebrevc($hebrew_text, $max_chars_per_line = 0) { }
function setlocale($category, $locale) { func_get_args();}
function localeconv() { }
function nl_langinfo($item) { }
function printf($format) { func_get_args();}
function vprintf($format, $args) { }
function sprintf($format) { func_get_args();}
function vsprintf($format, $args) { }
function sscanf($str, $format) { func_get_args(); }
function chr($ascii) { }
function ord($str) { }
function money_format($format, $number) { }
function number_format($number, $decimals = 0, $dec_point = ".", $thousands_sep = ",") { }
function strcmp($str1, $str2) { }
function strncmp($str1, $str2, $len) { }
function strnatcmp($str1, $str2) { }
function strcasecmp($str1, $str2) { }
function strncasecmp($str1, $str2, $len) { }
function strnatcasecmp($str1, $str2) { }
function strcoll($str1, $str2) { }
function substr_compare($main_str, $str, $offset, $length = 0, $case_insensitivity = false) { }
function strchr($haystack, $needle) { }
function strrchr($haystack, $needle) { }
function strstr($haystack, $needle) { }
function stristr($haystack, $needle) { }
function strpbrk($haystack, $char_list) { }
function strpos($haystack, $needle, $offset = 0) { }
function stripos($haystack, $needle, $offset = 0) { }
function strrpos($haystack, $needle, $offset = 0) { }
function strripos($haystack, $needle, $offset = 0) { }
function substr_count($haystack, $needle, $offset = 0, $length = 0x7FFFFFFF) { }
function strspn($str1, $str2, $start = 0, $length = 0x7FFFFFFF) { }
function strcspn($str1, $str2, $start = 0, $length = 0x7FFFFFFF) { }
function strlen($str) { }
function count_chars($str, $mode = 0) { }
function str_word_count($str, $format = 0, $charlist = "") { }
function levenshtein($str1, $str2, $cost_ins = 1, $cost_rep = 1, $cost_del = 1) { }
function similar_text($first, $second, &$percent = null) { }
function soundex($str) { }
function metaphone($str, $phones = 0) { }
function parse_str($str, &$arr = null) { }

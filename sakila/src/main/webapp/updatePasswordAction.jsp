<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%
	// controller 단
	Integer staffId = (Integer)(session.getAttribute("loginStaff"));
	if(staffId == null) { // 로그아웃 상태라면
		response.sendRedirect("/sakila/loginForm.jsp");
		return;
		
		
		
	}
	
	String password = request.getParameter("password");
	String newPassword = request.getParameter("newPassword");
	String passwordCheck = request.getParameter("passwordCheck");
		// 디버깅
		System.out.println("현재 비밀번호: " + password);
		System.out.println("새로운 비밀번호: " + newPassword);
		System.out.println("비밀번호확인: " + passwordCheck);
		
		if (password == null || newPassword == null || passwordCheck == null) {
			out.println("입력값이 누락되었습니다.");
			return;
		}	
		
	// model 단
	// 변수 받기
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	
	
	 // 1) mysql 드라이버에 로딩	
	Class.forName("com.mysql.cj.jdbc.Driver");
		// 디버깅
		System.out.println("드라이버 로딩 성공");
	 
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
		// 디버깅
		System.out.println("DB연결성공: " + conn);
		
	// 2) sql 준비
	String sql = "SELECT password FROM staff WHERE staff_id=?"; // 현재 비밀번호 가져오기
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, staffId);
	rs = stmt.executeQuery();

	if (rs.next()) {
		String dbPassword = rs.getString("password");
		
		
	
	if(!dbPassword.equals(password)) {
		// 현재 비밀번호가 틀림
		out.println("현재 비밀번호가 아닙니다.");
		return;
		
	} else if(newPassword.equals(password)) {
			// 새비밀번호가 기존비밀번호랑 일치할경우
			out.println("기존 비밀번호랑 같습니다.");
		return;
		
	} else if(!newPassword.equals(passwordCheck)) {
			// 비밀번호 확인 불일치
			out.println("새비밀번호가 일치하지 않습니다.");
			return;
	}
	
	// update 실행
	String updateSql = "UPDATE staff SET password = ? WHERE staff_id = ? AND password = ?";
	stmt = conn.prepareStatement(updateSql);
	stmt.setString(1, newPassword);
	stmt.setInt(2, staffId);
	stmt.setString(3, password);
	int row = stmt.executeUpdate(); // 영향을 받은 행의 개수 반환
	
	if(row == 1) {
		// 비밀번호 변경 성공
		System.out.print("비밀번호 변경되었습니다.");
		session.invalidate(); // 로그아웃
		//response.sendRedirect("/homeWork/loginForm.jsp");
	
%>
			<script>
				alert("비밀번호가 변경되었습니다. 다시 로그인해주세요.");
				location.href = "/homeWork/loginForm.jsp";
			</script>
<%
	} else {
		out.println("비밀번호 변경 실패");
	}
}
%>